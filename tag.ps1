for commit in $(git log --reverse --format=%H); do
    git tag v0.0.1 $commit -m "Tagging version 0.0.1"
done