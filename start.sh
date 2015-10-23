#!/bin/bash

chown -R buildguy:buildguy /home/buildguy/.m2/
chown -R buildguy:buildguy /home/buildguy/.ivy2/
chown -R buildguy:buildguy /home/buildguy/aggregate-metrics/

echo "Fetching git repo as gitguy"
sudo -i -H -u gitguy -- /scripts/git.py -a "$API_TOKEN" "$@"
find /home/gitguy -name '.git' | xargs rm -r
mv /home/gitguy/build-dir /home/buildguy/build-dir
chown -R buildguy:buildguy /home/buildguy/build-dir

echo "Running build as buildguy"
sudo -i -H -u buildguy -- /scripts/build.py "$@"

echo "Posting results as gitguy"
cp -r /home/buildguy/aggregate-metrics/ /home/gitguy/aggregate-metrics/
chown -R gitguy:gitguy /home/gitguy/aggregate-metrics/
sudo -i -H -u gitguy -- /scripts/updatePr.py -a "$API_TOKEN" "$@"
