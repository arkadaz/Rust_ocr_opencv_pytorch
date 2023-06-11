install:
	sudo apt update -y &&\
	sudo apt upgrade -y &&\
	sudo apt install build-essential -y &&\
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh &&\
	sudo apt-get install cargo &&\
	sudo apt install libopencv-dev clang libclang-dev &&\
	sudo apt install libstdc++-12-dev &&\
	sudo apt update -y &&\
	sudo apt upgrade -y &&\
	# wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin &&\
	# sudo mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600 &&\
	# wget https://developer.download.nvidia.com/compute/cuda/11.7.0/local_installers/cuda-repo-ubuntu1804-11-7-local_11.7.0-515.43.04-1_amd64.deb &&\
	# sudo dpkg -i cuda-repo-ubuntu1804-11-7-local_11.7.0-515.43.04-1_amd64.deb &&\
	# sudo cp /var/cuda-repo-ubuntu1804-11-7-local/cuda-*-keyring.gpg /usr/share/keyrings/ &&\
	# sudo apt-get update &&\
	# sudo apt-get -y install cuda &&\
	wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin &&\
	sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600 &&\
	wget https://developer.download.nvidia.com/compute/cuda/12.1.1/local_installers/cuda-repo-ubuntu2204-12-1-local_12.1.1-530.30.02-1_amd64.deb &&\
	sudo dpkg -i cuda-repo-ubuntu2204-12-1-local_12.1.1-530.30.02-1_amd64.deb &&\
	sudo cp /var/cuda-repo-ubuntu2204-12-1-local/cuda-*-keyring.gpg /usr/share/keyrings/ &&\
	sudo apt-get update &&\
	sudo apt-get -y install cuda &&\
	rm -rf libtorch &&\
	wget https://download.pytorch.org/libtorch/cu117/libtorch-cxx11-abi-shared-with-deps-2.0.0%2Bcu117.zip &&\
	unzip libtorch-cxx11-abi-shared-with-deps-2.0.0+cu117.zip &&\
	rm -rf libtorch-cxx11-abi-shared-with-deps-2.0.0+cu117.zip &&\
	echo 'export TORCH_CUDA_VERSION=cu117' >> ~/.bashrc &&\
	echo 'export LIBTORCH=/home/arkadaz/Program/Rust_ocr_opencv_pytorch-master/libtorch' >> ~/.bashrc &&\
	echo 'export LIBTORCH_INCLUDE=/home/arkadaz/Program/Rust_ocr_opencv_pytorch-master/libtorch/' >> ~/.bashrc &&\
	echo 'export LIBTORCH_LIB=/home/arkadaz/Program/Rust_ocr_opencv_pytorch-master/libtorch/' >> ~/.bashrc &&\
	echo 'export LD_LIBRARY_PATH=/home/arkadaz/Program/Rust_ocr_opencv_pytorch-master/libtorch/lib:$LD_LIBRARY_PATH' >> ~/.bashrc

format:
	cargo fmt --quiet

lint:
	cargo clippy --quiet

test:
	cargo test --quiet

clean:
	# cargo install cargo-cache
	# cargo cache -a
	# rm -rf Cargo.lock
	# cargo clean

run:
	cargo build -j 8
	cargo run --release

all: install run
