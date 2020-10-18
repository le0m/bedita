<?php

/**
 * Class for logging to Unix streams.
 */
class StreamLog
{
    /**
     * @var resource Handle for stdout stream
     */
    private $_stdout = null;

    /**
     * @var resource Handle for stderr stream
     */
    private $_stderr = null;


    /**
     * StreamLog constructor.
     *
     * @param array $options Unused
     * @throws BeditaInternalErrorException If opening the streams has failed
     */
    public function __construct(array $options = array())
    {
        $this->_stdout = $this->open('php://stdout');
        $this->_stderr = $this->open('php://stderr');
    }

    /**
     * StreamLog destructor.
     * 
     * @throws BeditaInternalErrorException If closing the streams has failed
     */
    public function __destruct()
    {
        $this->close($this->_stdout);
        $this->close($this->_stderr);
    }

    /**
     * Write a message to log stream.
     * 
     * @param string $type Log type to write
     * @param string $message Message to write
     * @return bool True on success
     * @throws BeditaInternalErrorException If the write failed
     */
    public function write($type, $message)
    {
        $output = sprintf(
            "%s %s: %s\n",
            date('Y-m-d H:i:s'),
            ucfirst($type),
            $message
        );
        
        switch ($type) {
            case 'error':
            case 'warning':
                $this->internalWrite($this->_stderr, $output);
                break;
                
            case 'notice':
            case 'info':
            case 'debug':
            default:
                $this->internalWrite($this->_stdout, $output);
        }
        
        return true;
    }

    /**
     * Write a message to an handle.
     * 
     * @param resource $handle Stream handle
     * @param string $message Message to write
     * @throws BeditaInternalErrorException If the write failed
     */
    protected function internalWrite($handle, $message)
    {
        if (!fwrite($handle, $message)) {
            $meta = stream_get_meta_data($handle);
            throw new BeditaInternalErrorException("Error writing to handle '{$meta['uri']}'");
        }
    }

    /**
     * Opens a stream for writing.
     * 
     * @param string $stream Stream URI
     * @return resource Stream handle
     * @throws BeditaInternalErrorException If the stream is not writable
     */
    protected function open($stream)
    {
        $handle = fopen($stream, 'w');
        
        if ($handle === false) {
            throw new BeditaInternalErrorException("Unable to open '{$stream}' for writing");
        }
        
        return $handle;
    }

    /**
     * Closes a stream handle.
     * 
     * @param resource $handle Stream handle
     * @throws BeditaInternalErrorException If the handle failed to close
     */
    protected function close($handle)
    {
        if (!fclose($handle)) {
            $meta = stream_get_meta_data($handle);
            throw new BeditaInternalErrorException("Unable to close handle for '{$meta['uri']}'");
        }
    }
}
