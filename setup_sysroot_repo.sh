#!/bin/bash

# Set the source and destination paths
SRC_DIR="/home/das/Downloads/go_hello_world_race"
DEST_DIR="/home/das/Downloads/bazel-sysroot"

# Create the repo structure
mkdir -p $DEST_DIR/{library,amd64,arm64}/sysroot

# Copy library files
echo "Copying library files..."
cp -r $SRC_DIR/sysroot-library/sysroot/library $DEST_DIR/library/sysroot/
cp $SRC_DIR/sysroot.BUILD $DEST_DIR/library/sysroot/

# Copy amd64 files
echo "Copying amd64 files..."
cp -r $SRC_DIR/sysroot-lib-amd64/sysroot/amd64 $DEST_DIR/amd64/sysroot/
cp $SRC_DIR/sysroot.BUILD $DEST_DIR/amd64/sysroot/

# Copy arm64 files
echo "Copying arm64 files..."
cp -r $SRC_DIR/sysroot-lib-arm64/sysroot/arm64 $DEST_DIR/arm64/sysroot/
cp $SRC_DIR/sysroot.BUILD $DEST_DIR/arm64/sysroot/

echo "Done! The files have been copied to $DEST_DIR"
echo "Run these commands to commit the changes:"
echo "cd $DEST_DIR"
echo "git add ."
echo "git commit -m 'Add sysroot files for library, amd64, and arm64'"
echo "git push origin main"