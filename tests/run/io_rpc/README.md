Basis.io_rpc and Basis.io_tryRpc: an RPC whose server function is an io
computation.  The run drives the RPC endpoints with curl, speaking the
protocol the browser's `rpc` speaks (POST, the arguments in the path, the
client named by the UrWeb-Client and UrWeb-Pass headers), and reads the
client's messages afterwards.  The C probes are those of ../io_task.
