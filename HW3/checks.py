import sys
import csv
from math import sqrt

def mean(xs):
    return sum(xs) / len(xs) if xs else 0

def sd(xs):
    if len(xs) < 2: return 0
    mu = mean(xs)
    return sqrt(sum((x - mu)**2 for x in xs) / len(xs))

def pearson(xs, ys):
    mx, my, n = mean(xs), mean(ys), len(xs)
    num = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    dx, dy = sum((x - mx)**2 for x in xs), sum((y - my)**2 for y in ys)
    return num / sqrt(dx * dy) if dx > 0 and dy > 0 else 0

def get_data(filename):
    with open(filename, 'r') as f:
        reader = csv.DictReader(f)
        cols, rows = reader.fieldnames, list(reader)
    data = {c: [] for c in cols}
    for r in rows:
        for c in cols:
            try: data[c].append(float(r[c]))
            except: data[c].append(r[c])
    return cols, data

def check_A(cols, data):
    groups = {}
    for c in cols:
        k = tuple(data[c])
        groups[k] = groups.get(k, []) + [c]
    [print(", ".join(g)) for g in groups.values() if len(g) > 1]

def is_num(lst):
    # Helper to check if a list is entirely numeric
    return all(isinstance(x, (int, float)) for x in lst)

def check_B(cols, data):
    # Only compare columns that are fully numeric
    nums = [c for c in cols if is_num(data[c])]
    for i, c1 in enumerate(nums):
        for c2 in nums[i+1:]:
            if abs(pearson(data[c1], data[c2])) > 0.95:
                print(f"{c1}, {c2}")

def check_C(cols, data):
    for c in cols:
        v = [x for x in data[c] if isinstance(x, (int, float))]
        if v and any(abs(x - mean(v)) > 3 * sd(v) for x in v):
            print(c)


# Counts missing values '?' as violations
def check_D(cols, data):
    col = {c: data[c] for c in cols}
    n = len(next(iter(col.values())))

    def v(c, i):
        return col[c][i] if c in col else None

    def num(x):
        return isinstance(x, (int, float))

    def check(target, involved, test):
        if not all(c in col for c in involved):
            return
        if any(test(i) for i in range(n)):
            print(target)

    check('AREA', ['HEIGHT', 'LENGHT', 'AREA'],
          lambda i: not all(num(v(c, i)) for c in ['HEIGHT', 'LENGHT', 'AREA'])
                    or v('HEIGHT', i) * v('LENGHT', i) != v('AREA', i))

    check('ECCEN', ['ECCEN', 'LENGHT', 'HEIGHT'],
          lambda i: not all(num(v(c, i)) for c in ['ECCEN', 'LENGHT', 'HEIGHT'])
                    or v('HEIGHT', i) == 0
                    or abs(v('ECCEN', i) - v('LENGHT', i) / v('HEIGHT', i)) > 0.01)

    check('P_BLACK', ['P_BLACK', 'BLACKPIX', 'AREA'],
          lambda i: not all(num(v(c, i)) for c in ['P_BLACK', 'BLACKPIX', 'AREA'])
                    or v('AREA', i) == 0
                    or abs(v('P_BLACK', i) - v('BLACKPIX', i) / v('AREA', i)) > 0.001)

    check('P_AND', ['P_AND', 'BLACKAND', 'AREA'],
          lambda i: not all(num(v(c, i)) for c in ['P_AND', 'BLACKAND', 'AREA'])
                    or v('AREA', i) == 0
                    or abs(v('P_AND', i) - v('BLACKAND', i) / v('AREA', i)) > 0.001)

# Counts missing values '?' as violations
def check_E(cols, data):
    col = {c: data[c] for c in cols}
    n = len(next(iter(col.values())))

    def v(c, i):
        return col[c][i] if c in col else None

    def num(x):
        return isinstance(x, (int, float))

    def check(involved, test):
        if not all(c in col for c in involved):
            return
        if any(test(i) for i in range(n)):
            print(", ".join(involved))

    for c in ['HEIGHT', 'LENGHT', 'WIDTH', 'AREA', 'BLACKPIX', 'BLACKAND', 'WB_TRANS', 'MEAN_TR', 'ECCEN']:
        check([c], lambda i, c=c: not num(v(c, i)) or v(c, i) <= 0)

    for c in ['P_BLACK', 'P_AND']:
        check([c], lambda i, c=c: not num(v(c, i)) or not (0 <= v(c, i) <= 1))

    check(['class!'],
          lambda i: not num(v('class!', i)) or v('class!', i) not in {1, 2, 3, 4, 5})

    check(['BLACKPIX', 'BLACKAND'],
          lambda i: not (num(v('BLACKPIX', i)) and num(v('BLACKAND', i))) or v('BLACKPIX', i) > v('BLACKAND', i))

def main():
    if len(sys.argv) < 3: return
    mode, filename = sys.argv[1], sys.argv[2]
    cols, data = get_data(filename)
    dispatch = {'A': check_A, 'B': check_B, 'C': check_C, 'D': check_D, 'E': check_E}
    if mode in dispatch:
        dispatch[mode](cols, data)

if __name__ == "__main__":
    main()