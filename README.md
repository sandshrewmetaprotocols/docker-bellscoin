# docker-bellscoin

Docker image forked from sandshrewmetaprotocols/docker-dogecoin, for bellscoin.

## Usage

```sh
git clone https://github.com/sandshrewmetaprotocols/docker-bellscoin --recurse-submodules
cd docker-bellscoin
docker build -t bellscoin .
docker run -it -p 19918:19918 bellscoin
```

## Author

Sandshrew Inc
