%undefine _hardened_build
%define _gprdir %_GNAT_project_dir
%define rtl_version 0.1

Name:       anagram
Version:    0.1.0
Release:    git%{?dist}
Summary:    Grammar handling and parser generation Ada library
Group:      Development/Libraries
License:    MIT
URL:        https://github.com/reznikmm/anagram
### Direct download is not availeble
Source0:    anagram.tar.gz
BuildRequires:   gcc-gnat
BuildRequires:   fedora-gnat-project-common  >= 3 
BuildRequires:   matreshka-devel
BuildRequires:   gprbuild

# gprbuild only available on these:
ExclusiveArch: %GPRbuild_arches

%description
Anagram is an Ada library to work with grammars of program languages.
It provides a type to represent classic grammar formalism including
BNF, extended BNF and attributed grammars, subprograms to construct, read
and convert them, some checks, parser generation, etc.

The Anagram makes it easy to create parsers of various kinds.

%package devel

Group:      Development/Libraries
License:    MIT
Summary:    Devel package for Ada Pretty
Requires:       %{name}%{?_isa} = %{version}-%{release}
Requires:   fedora-gnat-project-common  >= 2

%description devel
Devel package for Anagram

%prep 
%setup -q -n %{name}

%build
make  %{?_smp_mflags} GPRBUILD_FLAGS="%Gnatmake_optflags"

%install
rm -rf %{buildroot}
make install DESTDIR=%{buildroot} LIBDIR=%{_libdir} PREFIX=%{_prefix} GPRDIR=%{_gprdir} BINDIR=%{_bindir}

%post     -p /sbin/ldconfig
%postun   -p /sbin/ldconfig

%files
%doc LICENSE
%dir %{_libdir}/%{name}
%{_libdir}/%{name}/libanagram.so.%{rtl_version}
%{_libdir}/libanagram.so.%{rtl_version}
%{_libdir}/%{name}/libanagram.so.0
%{_libdir}/libanagram.so.0
%files devel
%doc README.md
%{_libdir}/%{name}/libanagram.so
%{_libdir}/libanagram.so
%{_libdir}/%{name}/*.ali
%{_includedir}/%{name}
%{_gprdir}/anagram.gpr
%{_gprdir}/manifests/anagram


%changelog
* Sat Nov 11 2017 Maxim Reznik <reznikmm@gmail.com> - 0.1.0-git
- Initial package
