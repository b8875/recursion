GENCODE_SM35     := -gencode arch=compute_35,code=sm_35
GENCODE_FLAGS    := $(GENCODE_SM35)

LDFLAGS   := -L/usr/local/cuda/lib64 -lcudart -lcudadevrt
CCFLAGS   := -m64

NVCCFLAGS := -m64 -dc

NVCC := nvcc
GCC := g++

# Debug build flags
ifeq ($(dbg),1)
      CCFLAGS   += -g
      NVCCFLAGS += -g -G
      TARGET := debug
else
      TARGET := release
endif


# Common includes and paths for CUDA
INCLUDES      := -I/usr/local/cuda/include -I. -I..

# Additional parameters
MAXRREGCOUNT  :=  -po maxrregcount=16

# Target rules
all: build

build: fac

fac.o: fac.cu
	$(NVCC) $(NVCCFLAGS) $(EXTRA_NVCCFLAGS) $(GENCODE_FLAGS) $(MAXRREGCOUNT) $(INCLUDES) $(LDFLAGS) -o $@ $<
	$(NVCC) -dlink  $(GENCODE_FLAGS) $(MAXRREGCOUNT) $(LDFLAGS) -o bs_link.o $@

fac: fac.o bs_link.o
	$(GCC) $(CCFLAGS) -o $@ $+ $(LDFLAGS) $(EXTRA_LDFLAGS)

run: build
	./fac
