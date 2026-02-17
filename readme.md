# IT3708 Project 2 – Genetic Algorithm

## Requirements

- Julia ≥ 1.10
- Git

Check your Julia version:

```bash
julia --version
```

---

## Setup

Clone the repository:

```bash
git clone <repository-url>
cd IT3708_Project_2
```

Install all dependencies:

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

This installs all required packages listed in `Project.toml` and `Manifest.toml`.

You only need to do this once.

---

## Running the Project

From the **project root directory** (the folder containing `Project.toml`), run:

```bash
julia --project=. src/main.jl
```

Important:

- Always run the command from the project root.
- Do not run `main.jl` without `--project=.`

---

## Project Structure

```
IT3708_Project_2/
│
├── Project.toml
├── Manifest.toml
├── src/
│   ├── main.jl
│   ├── load_data.jl
│   └── ...
├── data/
│   └── train_0.json
└── README.md
```

## Notes

- Data files must be located in the `data/` directory.
- File paths in the code are relative to the project root.
- The project uses a local Julia environment for reproducibility.
