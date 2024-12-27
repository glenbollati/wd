#!/usr/bin/python3
import pathlib
import sys

class WDTable():
    table: dict[str: pathlib.Path]
    path: str

    def __init__(self, path):
        self.table = {}
        self.path = path
        self.__load()


    def __str__(self):
        maxlen = 0
        for k in self.table:
            maxlen = max(maxlen, len(k))

        x = ""
        for k, v in sorted(self.table.items()):
            spaces = 1 + maxlen - len(k)
            x += f"{k}{' ' * spaces}{v}\n"

        return x.rstrip("\n")


    def __load(self):
        with open(self.path, "r") as f:
            lines = f.read().splitlines()

        for l in lines:
            spl = l.split(" ")
            k = spl[0]
            v = " ".join([x for x in spl[1:] if len(x)])
            self.table[k] = pathlib.Path(v)


    def __save(self):
        with open(self.path, "w") as f:
            f.write(str(self) + "\n")


    def print_stale(self):
        print("\n".join([str(p) for p in self.table.values() if not p.exists()]))


    def clear_stale(self):
        self.clear
        to_clear = [k for k in self.table if not self.table[k].exists()]
        self.clear(*to_clear)


    def set(self, k, v):
        self.table[k] = pathlib.Path(v).resolve()
        self.__save()


    def target(self, k):
        try:
            return self.table[k]
        except KeyError:
            return ""


    def clear(self, *keys):
        for k in keys:
            try:
                del self.table[k]
            except KeyError:
                pass
        self.__save()


    def clear_all(self):
        self.table = {}
        self.__save()


def help(exit_code=0):
    print(f"USAGE: {sys.argv[0]} h or --help")
    print(f"   OR: {sys.argv[0]} l or --list")
    print(f"   OR: {sys.argv[0]} s or --set")
    print(f"   OR: {sys.argv[0]} t or --target")
    print(f"   OR: {sys.argv[0]} c or --clear")
    print(f"   OR: {sys.argv[0]} --clear-all")
    print(f"   OR: {sys.argv[0]} --stale")
    print(f"   OR: {sys.argv[0]} --clear-stale")
    sys.exit(exit_code)


def main():
    wdfile = pathlib.Path.home() / ".wd"

    if len(sys.argv) < 2 or sys.argv[1] in ["-h", "--help"]:
        help()
    
    table = WDTable(wdfile)

    verb = sys.argv[1]
    key = None if len(sys.argv) < 3 else sys.argv[2]
    val = None if len(sys.argv) < 4 else sys.argv[3]

    if verb in ["l", "--list"]:
        print(table)
        sys.exit(0)

    elif verb in ["s", "--set"]:
        assert(key and val)
        table.set(key, val)

    elif verb in ["t", "--target"]:
        assert(key)
        print(table.target(key))

    elif verb in ["f", "--file"]:
        print(wdfile)

    elif verb in ["c", "--clear"]:
        assert(key)
        table.clear(key)

    elif verb == "--clear-all":
        table.clear_all()

    elif verb == "--stale":
        table.print_stale()

    elif verb == "--clear-stale":
        table.clear_stale()

    else:
        help(1)

if __name__  == "__main__":
    main()
