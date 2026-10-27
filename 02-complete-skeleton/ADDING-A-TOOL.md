# Hands-on: teach the agent a new skill (add a tool)

An agent can only do what its **tools** let it do. Let's prove it, then fix it.

## The problem

The example data stores sex as `F` and `M`. Ask the local agent to make it nicer:

```r
ask("Relabel the sex variable so it shows Female and Male, then give me Table 1 by sex")
```

It **can't**. The small local model will just call `make_table` again and talk about the
labels, because there is **no tool that renames categories**. A tool is the only way the agent
can actually change something.

So let's give it that tool. You will edit **one file**: `agent/tools.R`. You do **not** touch
`agent.R` (it automatically registers every tool you put in the `TOOLS` list).

---

## Step 1 — Write a function that does what you want

Open `agent/tools.R` and paste this **anywhere above** the `TOOLS <- list(...)` line at the very
bottom. Here it is first, then an explanation of every line.

```r
relabel <- function(variable, new_labels) {
  data <- get_data()
  labs <- trimws(strsplit(new_labels, ",")[[1]])
  data[[variable]] <- factor(data[[variable]], labels = labs)
  .state$data <- data
  paste0("Relabelled ", variable, " to: ", paste(labs, collapse = ", "))
}
```

Line by line:

- `relabel <- function(variable, new_labels) {`
  Defines a function called **relabel** that takes two inputs: `variable` (the column to
  change, e.g. `"sex"`) and `new_labels` (the new category names, e.g. `"Female,Male"`).
- `data <- get_data()`
  Gets the dataset that is currently loaded. `get_data()` is a small helper the other tools
  already use; it hands you the data table.
- `labs <- trimws(strsplit(new_labels, ",")[[1]])`
  Turns the text `"Female,Male"` into separate pieces. `strsplit(..., ",")` cuts the text at
  each comma; `[[1]]` takes that result as a plain vector; `trimws(...)` removes stray spaces.
  Result: `c("Female", "Male")`.
- `data[[variable]] <- factor(data[[variable]], labels = labs)`
  Rebuilds that column as a **factor** (a categorical variable) and assigns the new labels
  **in order**: the 1st category becomes `Female`, the 2nd becomes `Male`.
- `.state$data <- data`
  Saves the updated table back into the shared store, so the next tool (like `make_table`)
  uses the relabelled version. `.state` is just where the tools keep the loaded data.
- `paste0("Relabelled ", variable, " to: ", ...)`
  Builds a short confirmation message. **This text is what the function returns**, and it is
  what the agent reads back to know the tool worked.

---

## Step 2 — Wrap the function as a tool

Right below the function, paste this (again, explanation follows):

```r
tool_relabel <- tool(
  relabel,
  "Rename the categories of a variable, e.g. sex from F,M to Female,Male.",
  arguments = list(
    variable   = type_string("variable to relabel, e.g. 'sex'"),
    new_labels = type_string("new labels, comma-separated in order, e.g. 'Female,Male'")
  )
)
```

Line by line:

- `tool_relabel <- tool( ... )`
  `tool()` wraps your plain function so the agent can call it. We store the result in
  `tool_relabel`.
- `relabel,`
  The **first argument** is the function to run, the one you wrote in Step 1.
- `"Rename the categories of a variable, ..."`
  The **second argument** is the **description**. This is the single most important line: the
  model never sees your code, it only reads this sentence to decide *when* to use the tool.
  Write it in plain English and give an example.
- `arguments = list( ... )`
  Describes each input the model must provide, by name:
  - `variable = type_string("...")`
    Says the input `variable` is **text** (`type_string`), and the sentence in quotes explains
    what it is / shows an example, so the model fills it in correctly.
  - `new_labels = type_string("...")`
    Same idea: a **text** input with its explanation.
  - `type_string` just means "this input is a piece of text". (There is also `type_number`
    for numbers, `type_boolean` for yes/no, etc.)

---

## Step 3 — Register the tool

Find the last lines of `agent/tools.R`:

```r
TOOLS <- list(
  tool_load,
  tool_table,
  tool_model
)
```

Add your new tool to that list:

```r
TOOLS <- list(
  tool_load,
  tool_table,
  tool_model,
  tool_relabel
)
```

Save the file.

---

## Step 4 — Reload and try again

In the R console:

```r
source("agent.R")
ask("Relabel the sex variable: F is Female and M is Male, then give me Table 1 by sex")
```

Now it works: the agent calls your `relabel` tool, then `make_table`, and the table shows
**Female / Male**. You just taught the agent a new skill.

> With a small local model you sometimes need to be explicit (do the relabel **and** the
> table in one sentence, as above). A bigger agent like Claude Code (folder `03`) handles
> looser requests. Either way, the lesson is the same: **you expand what an agent can do by
> giving it tools.**
