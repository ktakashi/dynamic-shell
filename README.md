dynamic-shell
=============

This action allows you to dynamically resolve and customise shell.

This can be useful if you want to want to parameterise the shell,
e.g. bash vs powershell.

This is inspired by [dynamic-uses](https://github.com/marketplace/actions/dynamic-uses)

Usage
-----

Given a step like this:

```yaml
- shell: bash
  run: echo 'hello'
    
```

If you want to your `shell` to be dynamic, you can do:

```yaml
- use: ktakashi/dynamic-shell@v1
  with:
    shell: ${{ inputs.shell }}
    run: echo 'hello'
```

Possible useful usage
---------------------

Suppose you want to use images from vmactions. You probably want to write
your Actions like this
```yaml
jobs:
  Example:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        arch: [x86_64, aarch64]
        config:
          - { name: 'freebsd', script: 'freebsd.sh' }
          - { name: 'openbsd, script: 'openbsd.sh' }
    steps:
      - uses: actions/checkout@v4
      - uses: vmactions/${{ matrix.config.name }}-vm@
        with:
          arch: ${{ matrix.arch }}
          aync: nfs
      - shell: ${{ matrix.config.name }} {0}
        runs: ${{ matrix.config.script }}
```

However, this doesn't work. `dynamic-uses` resolves the dynamic action
issue. `dynamic-shell` resolves the dynamic shell issue. (possibly caused
by the same root cause?)

To make it happen, you can write like this:
```yaml
jobs:
  Example:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        arch: [x86_64, aarch64]
        config:
          - { name: 'freebsd', script: 'freebsd.sh' }
          - { name: 'openbsd, script: 'openbsd.sh' }
    steps:
      - uses: actions/checkout@v4
      - uses: jenseng/dynamic-uses@v1
        with:
          uses: vmactions/${{ matrix.config.name }}-vm@
          with: |
            {
              "arch": "${{ matrix.arch }}",
              "sync": "nfs"
            }
      - uses: ktakashi/dynamic-shell@v1
        with:
          shell: ${{ matrix.config.name }} {0}
          runs: ${{ matrix.config.script }}
```


Limitation
----------

Any outputs from the action will be serialized into a single outputs
JSON object string. You can then access things using helpers like
`fromJSON`, e.g. `fromJSON(steps.foo.outputs.outputs).something`

