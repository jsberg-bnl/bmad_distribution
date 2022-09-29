#!/bin/bash

echo "******* DEBUG ********"
dpkg -l pkg-config
ls -l /usr/share/aclocal/pkg.m4
aclocal --print-ac-dir
export ACLOCAL_PATH=/usr/share/aclocal
echo "******* DEBUG ********"

mkdir -p ~/artifact

mkdir -p ~/bmad
pushd ~/bmad

echo "**** Download and Extract Tarball"

# Download Bmad, extract and remove tarball
curl -O https://www.classe.cornell.edu/~cesrulib/downloads/tarballs/${BMADDIST}.tgz \
  && tar -xzf ${BMADDIST}.tgz \
  && rm -rf ${BMADDIST}.tgz

cd ${BMADDIST}

# Remove .svn folders
echo "**** Removing .svn folders"
find . -type d -iname .svn -print0 | xargs -0 rm -rf

echo "**** Compressing into tarball and saving into artifact folder."
# compress folder again into tarball
cd ..
tar -czf ${BMADDIST}.tgz ${BMADDIST}
# Move the clean tarball into the artifact folder
mv ${BMADDIST}.tgz ~/artifact/.

echo "**** Debug: Listing ~/artifact"
ls -lahtr ~/artifact/

# Start build process
mv ${BMADDIST} bmad_dist

cd bmad_dist

echo "**** Setup Preferences"

cat <<EOF >> ./util/dist_prefs
export DIST_F90_REQUEST="gfortran"
export ACC_PLOT_PACKAGE="pgplot"
export ACC_PLOT_DISPLAY_TYPE="X"
export ACC_ENABLE_OPENMP="Y"
export ACC_ENABLE_MPI="N"
export ACC_FORCE_BUILTIN_MPI="N"
export ACC_ENABLE_GFORTRAN_OPTIMIZATION="Y"
export ACC_ENABLE_SHARED="Y"
export ACC_ENABLE_SHARED_ONLY="Y"
export ACC_ENABLE_FPIC="Y"
export ACC_ENABLE_PROFILING="N"
export ACC_SET_GMAKE_JOBS="2"
EOF

echo "**** Invoking dist_source_me"
source ./util/dist_source_me

echo "**** Invoking dist_build_production"
./util/dist_build_production
