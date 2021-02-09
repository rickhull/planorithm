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
  - test: Know Mom's phone number
  - test: Phone
components:
  - action: Dial Mom's phone number
  - test: Phone is ringing
  - action: Wait for Mom to pick up
  - test: Mom has answered the call
  - iaction: Talk to Mom until finished
  - test: Call is finished
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
The first Node in `setup` has property `test` set to
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
      - test: Have Mom's number
  - name: Get Phone
    components:
      - iaction: Look for iPhone
      - iaction: Look for landline
      - test: Have a Phone
  - test: Phone works
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

* name (String)
* desc (String)
* action (String)
* iaction (String)
* test (String)
* setup (Array)
* components (Array)
* teardown (Array)

### Name

Generally every Node with children should have a name.

### Desc

Extremely optional.  A notes field.  Metadata stash. Whatever.

### Action

Just describe what you want to happen.  Magic robots will do it.
There can be only one Action per Node.  Create a Node with e.g.
Components when you want a sequence of Actions.

### IAction

Independent action.  Actions are run sequentially while
IActions run concurrently.  Maybe with a while or until
condition.  Maybe quickly.  Again, only one IAction per
Node, though a Node may have an Action as well.

### Test

A human will know what to do when the test fails.  Robots
should give up.  Tests are scheduled only once all
scheduled Actions and IActions complete.

### Setup

An array of Nodes.  Children.  The only thing special about
Setup is that it runs before Actions, IActions, Tests,
Components, and Teardown.  Often its children are very
simple nodes like `- action: Do the thing`.

### Components

Just like Setup, except Components runs after Setup, Actions,
IActions, and Tests, but before Teardown.

### Teardown

Just like Components except it runs last.  It is extremely
optional but often useful for completeness, to restore
state, or general cleanup, particularly of things created
during Setup.
