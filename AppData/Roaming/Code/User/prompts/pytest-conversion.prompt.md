---
mode: agent
---
## 🧪 Prompt: Convert Python Project from `unittest` to `pytest`

You will **migrate one test class at a time** from `unittest` to `pytest`.  Make a note of the number of tests for each class.

At every step:  
✅ All tests must still pass (`pytest`)  
✅ `ruff` must pass cleanly  
✅ Commit after each completed step  

---

### 🚀 **Step 1: Convert `assert*` methods**
- Replace all `self.assert*` methods with plain `assert` statements:
  - `assertEqual(a, b)` → `assert a == b`
  - `assertNotEqual(a, b)` → `assert a != b`
  - `assertTrue(x)` → `assert x`
  - `assertFalse(x)` → `assert not x`
  - `assertIsNone(x)` → `assert x is None`
  - `assertIsNotNone(x)` → `assert x is not None`
  - `assertIn(a, b)` → `assert a in b`
  - `assertNotIn(a, b)` → `assert a not in b`
  - `assertIs(a, b)` → `assert a is b`
  - `assertIsNot(a, b)` → `assert a is not b`
  - `assertGreater(a, b)` → `assert a > b`
  - `assertGreaterEqual(a, b)` → `assert a >= b`
  - `assertLess(a, b)` → `assert a < b`
  - `assertLessEqual(a, b)` → `assert a <= b`
- `self.assertRaises(Exception, func, *args)` →  
  `with pytest.raises(Exception): func(*args)`

---

### 🧹 **Step 2: Replace `setUp` / `tearDown`**
- Convert `setUp()` → `setup_method(self)`
- Convert `tearDown()` → `teardown_method(self)`
- If shared resources apply to all tests, consider extracting into `@pytest.fixture(autouse=True)`

Reference:  
https://docs.pytest.org/en/stable/how-to/xunit_setup.html

---

### 🧩 **Step 3: Replace `subTest()`**
- Convert `with self.subTest(...):` blocks into `@pytest.mark.parametrize()` decorators.

Example:  
```python
with self.subTest(value=v):
    self.assertEqual(foo(v), expected)
```
→
```python
@pytest.mark.parametrize("value,expected", [...])
def test_foo(value, expected):
    assert foo(value) == expected
```

Reference:
https://docs.pytest.org/en/stable/how-to/parametrize.html

### ✂️ Step 4: Remove unittest imports

- Delete import unittest
- Remove unittest.TestCase inheritance (class MyTest:)

### Step 5: Simplify test runners

- Remove any calls to unittest.main()
- Remove any if __name__ == "__main__": blocks
- Ensure tests can be run simply by invoking: `pytest`

Reference:
https://docs.pytest.org/en/stable/explanation/goodpractices.html#choosing-a-test-layout

### Step 6: Verify discovery

Confirm pytest discovers all tests automatically:
- Test functions start with test_
- Test files start or end with test

### Step 7: Refactor fixtures

- Convert shared state to @pytest.fixture
- Remove redundant setup_method or teardown_method if fixtures fully replace them

Reference:
https://docs.pytest.org/en/stable/how-to/fixtures.html

## Step 8: Remove unnecessary TestCase class

- Remove classes that only contain tests
- Convert remaining test methods to standalone functions

## ✅ After Each Stage

- Run `pytest` — all tests must pass
- Run `ruff check .` — no lint errors allowed
- Fix all failures or lint issues before moving to the next class or stage
- Make sure the number of tests remains the same or increases
- Review the file and simplify where possible

## ✅ When the last stage is complete

- Commit changes with the message "refactor(TestFoo): convert to pytest"
- go to the next class and repeat the process.