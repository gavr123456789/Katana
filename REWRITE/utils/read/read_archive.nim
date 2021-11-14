import zippy/tarballs
### TESTS
# create from current directore
createTarball("../read", "examples.tar.gz")
# open it
var tarbol = Tarball()
tarbol.open("examples.tar.gz")
echo tarbol.contents

# import zippy/ziparchives

# createZipArchive("../utils", "examples.zip")