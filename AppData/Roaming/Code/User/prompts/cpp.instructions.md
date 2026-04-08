---
applyTo: '**/*.cpp'
description: 'Guidance specific to C++ code generation and modification tasks'
---

# C++ Specific Guidance

- Follow the [C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines) and modern C++ best practices.  Make a note of the anchors in the file so you can later reference the guideline with the appropriate link.
- Consider guidelines in generic.instructions.md as well.

## Concurrency and Multithreading

- Pay special attention to multithreading and concurrency issues.

## Style

- Follow conventions listed in the .clang-format file in the repository if there is one.
- Use modern C++ features (C++11 and later) where possible and appropriate (e.g., smart pointers, range-based for loops, auto keyword).
- auto: Use `auto` when the type is obvious from the right-hand side of the assignment or when the exact type is not important. Avoid `auto` when it makes the code less readable.

## Tasks

- In the absence of specific instructions, run `make` to learn about the project's targets.

# Testing

- Use modern versions `gtest` and `gmock` frameworks with `MOCK_METHOD`.
- Prefer `ASSERT_THAT` and `EXPECT_THAT` to default `gtest` macros.
