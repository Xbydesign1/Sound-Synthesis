/*
 * This file is part of Beads. See http://www.beadsproject.net for all information.
 */
import beads.*;

/**
 * Creates a {@link Buffer} consisting of a Cosine wave in the range [-1,1].
 * 
 * @see Buffer BufferFactory
 * @author ollie
 */
public class CosineBuffer extends BufferFactory {
    /* (non-Javadoc)
     * @see net.beadsproject.beads.data.BufferFactory#generateBuffer(int)
     */
    public Buffer generateBuffer(int bufferSize) {
      Buffer b = new Buffer(bufferSize);
        for(int i = 0; i < bufferSize; i++) {
            b.buf[i] = (float)Math.cos(2.0 * Math.PI * (double)i / (double)bufferSize);
        }
      return b;
    }

    /* (non-Javadoc)
     * @see net.beadsproject.beads.data.BufferFactory#getName()
     */
    public String getName() {
      return "Cosine";
    }
}
