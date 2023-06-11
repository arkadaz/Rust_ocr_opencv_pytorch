install:
	sudo apt update -y &&\
	sudo apt upgrade -y &&\
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh &&\
	sudo apt install libopencv-dev clang libclang-dev &&\
	wget https://developer.download.nvidia.com/compute/cuda/12.1.1/local_installers/cuda_12.1.1_530.30.02_linux.run &&\
	sudo sh cuda_12.1.1_530.30.02_linux.run &&\
	rm -rf cuda_12.1.1_530.30.02_linux.run &&\
	rm -rf libtorch &&\
	wget https://download.pytorch.org/libtorch/cu117/libtorch-cxx11-abi-shared-with-deps-1.13.1%2Bcu117.zip &&\
	unzip libtorch-cxx11-abi-shared-with-deps-1.13.1+cu117.zip &&\
	rm -rf libtorch-cxx11-abi-shared-with-deps-1.13.1+cu117.zip &&\
	echo 'export TORCH_CUDA_VERSION="cu117"' >> ~/.bashrc &&\
	echo 'export LIBTORCH="/home/arkadaz/Test_rust/Rust_ocr_opencv_pytorch/libtorch"' >> ~/.bashrc &&\
	echo 'export LD_LIBRARY_PATH=${LIBTORCH}/lib' >> ~/.bashrc

format:
	cargo fmt --quiet

lint:
	cargo clippy --quiet

test:
	cargo test --quiet

clean:
	cargo install cargo-cache
	cargo cache -a
	rm -rf Cargo.lock
	cargo clean

run:
	cargo build -j 8
	cargo run --release

all: install clean format lint test run