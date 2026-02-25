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

def is_num(x):
    # Helper to check if a single value is numeric
    return isinstance(x, (int, float))

def check_B(cols, data):
    # Only compare columns that are fully numeric
    nums = [c for c in cols if all(is_num(x) for x in data[c])]
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


def get_row_indices(data):
    return range(len(next(iter(data.values()))))

def check_G(cols, data):
    """Outlier cases: rows with at least one value > 3σ from column mean."""
    outlier_rows = set()
    for c in cols:
        vals = [x for x in data[c] if is_num(x)]
        if not vals: continue
        mu, sigma = mean(vals), sd(vals)
        if sigma == 0: continue
        for i in get_row_indices(data):
            if is_num(data[c][i]) and abs(data[c][i] - mu) > 3 * sigma:
                outlier_rows.add(i + 1)
    return outlier_rows

def check_H(cols, data):
    """Inconsistent cases: identical features but different class!"""
    features = [c for c in cols if c != 'class!']
    seen = {} # {feature_tuple: set(classes)}
    inconsistent = set()
    for i in get_row_indices(data):
        feats = tuple(data[c][i] for c in features)
        cls = data['class!'][i]
        if feats not in seen: seen[feats] = set()
        seen[feats].add(cls)
    
    for i in get_row_indices(data):
        feats = tuple(data[c][i] for c in features)
        if len(seen[feats]) > 1:
            inconsistent.add(i + 1)
    return inconsistent

def check_I(cols, data):
    """Class-conditional outliers: > 3σ from class-specific mean."""
    classes = set(data['class!'])
    stats = {cls: {} for cls in classes}
    for cls in classes:
        indices = [i for i in get_row_indices(data) if data['class!'][i] == cls]
        for c in cols:
            if c == 'class!': continue
            c_vals = [data[c][i] for i in indices if is_num(data[c][i])]
            if c_vals: stats[cls][c] = (mean(c_vals), sd(c_vals))
            
    outliers = set()
    for i in get_row_indices(data):
        cls = data['class!'][i]
        for c, (mu, sigma) in stats[cls].items():
            if sigma > 0 and is_num(data[c][i]) and abs(data[c][i] - mu) > 3 * sigma:
                outliers.add(i + 1)
                break
    return outliers

def check_J(cols, data):
    """Cases with conflicting values: violating referential integrity."""
    conflicts = set()
    for i in get_row_indices(data):
        v = {c: data[c][i] for c in cols}
        # Skip if any required field is '?' (non-numeric string)
        try:
            # AREA = HEIGHT * LENGHT
            if abs(v['HEIGHT'] * v['LENGHT'] - v['AREA']) > 0.001: conflicts.add(i+1)
            # ECCEN = LENGHT / HEIGHT
            elif v['HEIGHT'] == 0 or abs(v['ECCEN'] - (v['LENGHT'] / v['HEIGHT'])) > 0.01: conflicts.add(i+1)
            # P_BLACK = BLACKPIX / AREA
            elif v['AREA'] == 0 or abs(v['P_BLACK'] - (v['BLACKPIX'] / v['AREA'])) > 0.001: conflicts.add(i+1)
            # P_AND = BLACKAND / AREA
            elif v['AREA'] == 0 or abs(v['P_AND'] - (v['BLACKAND'] / v['AREA'])) > 0.001: conflicts.add(i+1)
        except (TypeError, ValueError): continue 
    return conflicts

def check_K(cols, data):
    """Cases with implausible values: violating plausibility constraints."""
    implausible = set()
    pos_fields = ['HEIGHT', 'LENGHT', 'WIDTH', 'AREA', 'BLACKPIX', 'BLACKAND', 'WB_TRANS', 'MEAN_TR', 'ECCEN']
    for i in get_row_indices(data):
        v = {c: data[c][i] for c in cols}
        # Positivity
        if any(not is_num(v[c]) or v[c] <= 0 for c in pos_fields): implausible.add(i+1)
        # Probabilities
        elif any(not is_num(v[c]) or not (0 <= v[c] <= 1) for c in ['P_BLACK', 'P_AND']): implausible.add(i+1)
        # Class range
        elif v['class!'] not in {1, 2, 3, 4, 5}: implausible.add(i+1)

    return implausible

def check_L(cols, data):
    """Total data-quality problem cases: Union of G-K."""
    return check_G(cols, data) | check_H(cols, data) | check_I(cols, data) | check_J(cols, data) | check_K(cols, data)

def check_M(cols, data):
    """Total problem cases (alias for L)."""
    return check_L(cols, data)

def main():
    if len(sys.argv) < 3: return
    mode, filename = sys.argv[1], sys.argv[2]
    cols, data = get_data(filename)
    dispatch = {'A': check_A, 'B': check_B, 'C': check_C, 'D': check_D, 'E': check_E, 'G': check_G, 'H': check_H, 'I': check_I, 'J': check_J, 'K': check_K, 'L': check_L, 'M': check_M}
    prints = {'A', 'B', 'C', 'D', 'E'}
    if mode in prints:
        dispatch[mode](cols, data)
    elif mode in dispatch:
        result = dispatch[mode](cols, data)
        for row in sorted(result):
            print(row)

if __name__ == "__main__":
    main()