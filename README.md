# Planorithm

## Rationale

I love outlines.  Sections, breakdowns, steps, categories.
Get the prose out of the way and give me relationships --
an overview of the overall structure.  The conventional
outline tools never seem to quite fit my use case.
I, II, III, A, B, C, etc.
We need more than nested `<ul>` and `<ol>` in order to
have enough structure yet enough flexibility.

What Planorithm offers is a slight twist on the conventional
outline format.  It's useful for structured documents --
planning documents that will have to be executed someday.

Maybe you are writing a test plan for a piece of equipment
or software.  Maybe it's a recipe for chicken soup?
What's in common?  A sequence of steps.
Often some prep or setup before the main steps.
Maybe some cleanup afterward.
We call this the hamburger model:

* Bun (Setup)
* Meat (Components)
* Bun (Teardown)

Any step (Node, really) can be recursively defined according
to the hamburger model.
Every step is a potential hamburger that can be expanded to
Setup, Components, Teardown.

Consider a simple task: Call Mom

```
action: Call Mom
```

We have created a Node that has `action` property set to
"Call Mom".  We haven't really expressed how to call Mom
here.  Let's explode the hamburger:

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

We have created a Node that has `name` property set to
"Call Mom".
This Node could have an `action` property but it does
not.
It has two other properties: `setup` and `components`.
Along with `teardown`, these properties always
represent a collection -- an ordered sequence of
child Nodes.
The first Node in `setup` has property `check` set to
"Know Mom's phone number".
You can probably figure out the rest.

Now, you may ask, "What if I don't know Mom's phone
number"?  Fine, you can explode that hamburger too:

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

You can make this plan as detailed and foolproof
as you want.
What you can't have here is conditional branches
in the flow.
This is a current and expected limitation of
this model.
It is hoped that extensions may be able to
provide conditional branching in a satisfying
way.

## Details

A `Node` consists of 8 properties, all of which are
optional:

Purely Metadata:

* name (String)
* desc (String)

Tasks:

* action (String)
* iaction (String)
* check (String)

Children:

* setup (Array of Nodes)
* components (Array of Nodes)
* teardown (Array of Nodes)

### Name

*Metadata*

Generally every Node with children should have a name.

### Desc

*Metadata*

Extremely optional.  A notes field.  Metadata stash. Whatever.

### Action

*Task*

Just describe what you want to happen.  Magic robots will do it.
There can be only one Action per Node.  Create a Node with e.g.
Components when you want a sequence of Actions.

### IAction

*Task*

Independent action.  Actions are run sequentially while
IActions run concurrently.  Maybe with a while or until
condition.  Maybe quickly once.  Again, only one IAction per
Node, though that Node may have an Action and Check as well.

### Check

*Task*

A human will know what to do when the check fails.  Robots
should give up.  Checks are scheduled only once all
scheduled Actions and IActions complete.

### Setup

*Collection of Nodes*

An array of Nodes.  Children.  The only thing special about
Setup is that it runs before Actions, IActions, Checks,
Components, and Teardown.  Often its children are very
simple nodes like `- action: Do the thing`.

### Components

*Collection of Nodes*

Just like Setup, except Components runs after Setup, Actions,
IActions, and Checks, but before Teardown.

### Teardown

*Collection of Nodes*

Just like Components except it runs last.  It is extremely
optional but often useful for completeness, to restore
state, or general cleanup, particularly of things created
during Setup.

## Task Scheduling

*Nothing happens* in Planorithm until we can schedule a
Task.  There are only 3 types of Task:

* `action`
* `iaction`
* `check`

A Node may include all 3 types, in which case the order
of scheduling is:

1. `iaction`
2. `action`
3. `check`

The `iaction` is scheduled first.
The scheduler returns immediately upon receiving an `iaction`.
The `action` is scheduled next.
The scheduler immediately returns a handle to wait for completion.
The `check` is scheduled last.
The scheduler immediately returns a handle to wait for completion.
As long as there are `action`s and `iaction`s running, the scheduler
will wait to execute any `check`s in the queue.

Now, what about scheduling across an array of Nodes?

#### Scheduling Across an Array of Nodes

Let's imagine some `components`:

```
components:
  - action: start db
  - check: is db running?
  - iaction: while db is running, monitor the db
  - iaction: ping slack channel
  - action: start app
  - check: is app running?
```

##### Rules

1. Tasks are scheduled sequentially
2. Execution happens "later" in a separate thread
3. `check`s are blocked by everything
4. `iaction`s are blocked by `check`s
5. `action`s are blocked by `action`s and `check`s
6. `check`s block everything
7. `iaction`s block `check`s
8. `action`s block `action`s

##### Tasks are scheduled sequentially.

First we "start db".
The following `check` will not execute until that `action`
has been completed.
Only once the `check` has passed will the following
`iaction`s be scheduled.
The first `iaction` will "monitor the db" "while db is running"
The second `iaction` will execute concurrently with the first
and "ping slack channel".

##### `iaction` execution does not block `action` execution

The "start app" `action` will be scheduled immediately
and run as soon as any prior `action` completes.

##### An executing `check` will block all subsequently scheduled
tasks from executing

`check`s clear the board.  They will not run until all prior
`action`s and `iaction`s complete, and their execution will
block the execution of subsequently scheduled `action`s and
`iaction`s.
