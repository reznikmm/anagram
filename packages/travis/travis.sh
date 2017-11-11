function linux_before_install()
{
    cp -r packages/travis /tmp/
    cd ..
    tar --exclude=.git \
        -c -z -f /tmp/travis/anagram.tar.gz anagram
    docker build --tag anagram /tmp/travis/
}

function linux_script()
{
    umask og+w
    mkdir upload
    docker run -i -t -v$(pwd)/upload:/upload --user=max anagram \
           /bin/bash -c \
           'rpmbuild -bb /src/anagram.spec --define "_rpmdir /upload"'

}

${TRAVIS_OS_NAME}_$1
