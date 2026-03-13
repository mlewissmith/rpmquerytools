# rpmquerytools

Tools to query installed package RPMs

```
Provides tools:

    rpmlsf - list contents of rpm packages (long format)
    rpmwhat - list dependencies of rpm packages
    rpmwhy - list dependents of rpm packages
```

## Obtaining

The latest release of **rpmquerytools** can be downloaded from
[github](https://github.com/mlewissmith/rpmquerytools/releases)
or cloned with
```
git clone https://github.com/mlewissmith/rpmquerytools
```

## Compiling

**rpmquerytools** uses the
[meson](https://mesonbuild.com)
build system to configure, compile and install.
```
meson setup BUILDDIR
meson compile -C BUILDDIR
meson install -C BUILDDIR
```

> [!TIP]
> * List all available build options with
>   `meson configure BUILDDIR`
> * Set build options with
>   `meson configure BUILDDIR -D OPTION=VALUE ...`
> * Influential build options include
>   - `prefix`
>   - `with-bash-completions`
>   - `with-manpages`
>   - `with-manformats`

## Manifest

### rpmlsf - list contents of rpm packages (long format)

**rpmlsf**(1) lists the contents of the installed rpm package *PACKAGENAME* or
the local (s)rpm package file *FILENAME*.

### rpmwhat - list dependencies of rpm packages

**rpmwhat**(1) lists the package dependencies of a given *PACKAGENAME*, or the
package dependencies of the package owning a given *FILENAME* or *CAPABILITY*.

### rpmwhy - list dependents of rpm packages

**rpmwhy**(1) lists the dependent packages of a given *PACKAGENAME*, or the
dependent packages of the package owning a given *FILENAME* or
*CAPABILITY*.
