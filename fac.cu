#include <cuda_runtime.h>
#include <stdio.h>

#define N 16

__global__ void factd(int64_t *array, int n, int index){

	if (n > 0){
		factd<<<1, 1>>>(array, n - 1, index);
		array[index] +=  n;	
	}
}

__global__ void factorial(int64_t *array){
	int id = threadIdx.x + blockDim.x * blockIdx.x;
	factd<<<1, 1>>>(array, id, id);

}


int main()
{
	int64_t* host = new int64_t[N];
	int64_t* device;
	cudaMalloc( (void**)&device, N * sizeof( int64_t ) );
	size_t pValue;
        cudaDeviceSetLimit(cudaLimitStackSize, 8192);
        cudaDeviceGetLimit(&pValue, cudaLimitStackSize);

	for( unsigned int i = 1; i < N; ++i )
	{
		host[i] = 0;
	}

	cudaMemcpy( device, host, N * sizeof( int64_t ), cudaMemcpyHostToDevice );
	
	cudaEvent_t     start, stop;
        cudaEventCreate(&start);
        cudaEventCreate(&stop);
        cudaEventRecord(start, 0);

	factorial<<< 1, N >>>( device );
	
	cudaEventRecord(stop, 0);
        cudaEventSynchronize(stop);

        float elapsedTime;
        cudaEventElapsedTime(&elapsedTime, start, stop);
        cudaEventDestroy(start);
        cudaEventDestroy(stop);

	printf("%f ms\n",elapsedTime);
	cudaMemcpy( host, device, N * sizeof( int64_t ), cudaMemcpyDeviceToHost );
#if 0
	for (int i = 0; i < N; i++){
		printf("%ld, %d\n", host[i], i);
	}
#endif 
	cudaFree( device );
	delete[] host;
}
