# Planorithm

## Rationale

I love outlines.  Sections, breakdowns, steps, categories.
Get the prose out of the way and give me relationships -- an overview
of the overall structure.
The conventional outline tools never seem to quite fit my use case.
I, II, III, A, B, C, etc.
We need more than nested `<ul>` and `<ol>` in order to have enough
structure yet enough flexibility.

### Use Cases

What **Planorithm** offers is a slight twist on the conventional outline
format.  It's useful for structured documents:

* Technical documents
* Planning documents
* Assembly documents
* Recipes
* Test plans
* Pseudocode
* UX flows
* General instructions
* *Automate Everything*

### Hamburger Model

Maybe you are writing a test plan for a piece of equipment or software.
Maybe it's a recipe for [chicken soup](examples/chicken_soup.yaml)?
What's in common?  A sequence of steps.
Often some prep or setup before the main steps.
Maybe some cleanup afterward.
We call this the hamburger model:

* Bun (Setup)
* Meat (Components)
* Bun (Teardown)

Any step (*Node*, really) can be recursively defined according to the
hamburger model.
Every step is a potential hamburger that can be expanded to:
**Setup, Components, Teardown**.

### Call Mom Example

Consider a simple task: "Call Mom"

```
action: Call Mom
```

We have created a *Node* that has `action` property set to "Call Mom".
We haven't really expressed how to call Mom here.
Let's explode the hamburger:

```
name: Call Mom
setup:
  - check: Know Mom's phone number
  - check: Phone
components:
  - action: Dial Mom's phone number
  - check: Phone is ringing
  - action: Wait for Mom to pick up
  - check: Mom has answered the call
  - iaction: Talk to Mom until finished
  - check: Call is finished
  - action: Hang up phone
```

We have created a *Node* that has `name` property set to "Call Mom".
This *Node* could have an `action` property but it does not.
It has two other properties: `setup` and `components`.
Along with `teardown`, these properties always represent a collection --
an ordered sequence of child *Nodes*.
The first *Node* in `setup` has property `check` set to
"Know Mom's phone number".
You can probably figure out the rest.

Now, you may ask, "What if I don't know Mom's phone number"?
Fine, you can explode that hamburger too:

```
name: Call Mom
setup:
  - name: Get Mom's Phone Number
    components:
      - iaction: Search iPhone for Mom's number
      - iaction: Check fridge for Mom's number
      - iaction: Remember Mom's number
      - check: Have Mom's number
  - name: Get Phone
    components:
      - iaction: Look for iPhone
      - iaction: Look for landline
      - check: Have a Phone
  - check: Phone works
```

You can make this plan as detailed and foolproof as you want.
What you can't have here is conditional branches in the flow.
This is a current and expected limitation of this model.
It is hoped that extensions may be able to provide conditional branching
in a satisfying way.



## Details

A *Node* consists of only 8 properties, all of which are **optional**:

* `name` (String)
* `desc` (String)
* `action` (String)
* `iaction` (String)
* `check` (String)
* `setup` (Array)
* `components` (Array)
* `teardown` (Array)

### `name`

*Metadata* -
Any *Node* with children or multiple *Tasks* should have a `name`.

### `desc`

*Metadata* - **Extremely optional**.  A notes field.  Metadata stash.
Whatever.

### `action`

*Task* - Just describe what you want to happen.
Highlander robots will do it.
There can be only one `action` per *Node*.
Create a *Node* with `components` when you want a sequence of `action`.

### `iaction`

*Task* - Independent action.
`action` runs sequentially while `iaction` runs concurrently.
Maybe quickly once.  Maybe periodically "while true".
One `iaction` per *Node*, though that *Node* may have an `action`
and `check` as well.

### `check`

*Task* - A human will know what to do when the `check` fails.
Robots should give up.
`check` executes after `setup`, `iaction`, `action`, `components`.

### `setup`

*Collection of Nodes* - Children.
The only thing special about `setup` is that it runs before `action`s,
`iaction`s, `check`s, `components`, and `teardown`.
Often its children are very simple nodes like `action: Do the thing`.

### `components`

*Collection of Nodes* - Just like `setup`, except `components` runs after
`setup`, `action`, and `iaction`, but before `check` and `teardown`.

### `teardown`

*Collection of Nodes* - Just like `components` except it runs last.
It is **extremely optional** but often useful for completeness, to restore
state, or general cleanup, particularly of things created during `setup`.



## Task Scheduling

*Nothing happens* in Planorithm until we can schedule a *Task*.
There are only 3 types of *Task*, executing (roughly) in order:

1. `iaction`
2. `action`
3. `check`

### Rules

1. *Tasks* are scheduled sequentially
2. Execution happens "later" in a separate thread
3. `iaction` blocks `check`
4. `action` blocks `action` and `check`
5. `check` blocks `action` and `iaction`

### Node Scheduling

As above: `iaction`, `action`, `check`

### Scheduling Across an Array of Nodes

```
components:
  - action: start db
  - check: is db running?
  - iaction: while db is running, monitor the db
  - iaction: ping slack channel
  - action: start app
  - check: is app running?
```

#### *Tasks* are scheduled sequentially.

First we "start db".
The following `check` will not execute until that `action`
has been completed.
Only once the `check` has passed will the following
`iaction`s be scheduled.
The first `iaction` will "monitor the db" "while db is running"
The second `iaction` will execute concurrently with the first
and "ping slack channel".

#### `action` not blocked by `iaction`

The "start app" `action` will be scheduled immediately
and run as soon as any prior `action` completes.

##### `check` is blocked by and will block everything

`check` clears the board.  It will not run until all prior `action` and
`iaction` complete, and their execution will block the execution of
subsequently scheduled `action` and `iaction`.

### Combined Scheduling

1. Schedule `setup` and all its children; wait for completion
2. Schedule `iaction`; proceed immediately
3. Schedule `action`; wait for completion
4. Schedule `components` and all its children; wait for completion
5. Schedule `check` upon completion of `iaction`, `action`, and
   `components`; wait for completion
6. Schedule `teardown`

## Formats

**Planorithm** is a methodology for writing structured documents.
These documents can take many forms:

* Hashes, Strings, and Arrays
* YAML
* JSON
* Markdown

**Planorithm** aims to convert faithfully between all of these formats
so that you can express and execute your structured documents in a
satisfying way.

### YAML

The current default format for a Planorithm document.  Input and Output.

### JSON

First-class citizen alongside YAML. Input and Output.

### Markdown

In-progress.  More of an output format than an input format.
