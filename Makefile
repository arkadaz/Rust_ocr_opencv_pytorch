install:
	apt install libopencv-dev clang libclang-dev &&\
	wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin &&\
	sudo mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600 &&\
	wget https://developer.download.nvidia.com/compute/cuda/11.7.0/local_installers/cuda-repo-ubuntu1804-11-7-local_11.7.0-515.43.04-1_amd64.deb &&\
	sudo dpkg -i cuda-repo-ubuntu1804-11-7-local_11.7.0-515.43.04-1_amd64.deb &&\
	sudo cp /var/cuda-repo-ubuntu1804-11-7-local/cuda-*-keyring.gpg /usr/share/keyrings/ &&\
	sudo apt-get update &&\
	sudo apt-get -y install cuda &&\
	rm -rf libtorch &&\
	wget https://download.pytorch.org/libtorch/cu117/libtorch-cxx11-abi-shared-with-deps-1.13.1%2Bcu117.zip &&\
	unzip libtorch-cxx11-abi-shared-with-deps-1.13.1+cu117.zip &&\
	rm -rf libtorch-cxx11-abi-shared-with-deps-1.13.1+cu117.zip
format:
	cargo fmt --quiet

lint:
	cargo clippy --quiet

test:
	cargo test --quiet

clean:
	#cargo install cargo-cache
	#cargo cache -a
	#rm -rf Cargo.lock
	cargo clean

run:
	cargo run 

all: install format lint test run