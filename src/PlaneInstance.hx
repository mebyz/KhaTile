package;

import kha.Framebuffer;
import kha.Color;
import kha.graphics4.CullMode;
import kha.math.Random;
import kha.math.Vector3;
import kha.math.Vector4;
import kha.Scheduler;
import kha.Shaders;
import kha.Assets;
import kha.graphics4.CompareMode;
import kha.graphics4.FragmentShader;
import kha.graphics4.IndexBuffer;
import kha.graphics4.PipelineState;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;
import kha.math.Matrix4;

class PlaneInstance {

	var vertexBuffer:VertexBuffer;
	var indexBuffer:IndexBuffer;
	var pipeline:PipelineState;

	public function new() {

		var v:Array<Float> = new Array();
		var ind:Array<Int> = new Array();

		for (i in 0...10) {

			for (j in 0...10) {

				v.push(-0.1*i);v.push(-0.1*j);v.push(0.0);
				v.push(0.1*i);v.push(-0.1*j);v.push(0.0);
				v.push(-0.1*i);v.push(0.1*j);v.push(0.0);
				v.push(0.1*i);v.push(0.1*j);v.push(0.0);

				ind.push((i*10+j)*4);
				ind.push((i*10+j)*4+1);
				ind.push((i*10+j)*4+2);

				ind.push((i*10+j)*4+1);
				ind.push((i*10+j)*4+2);
				ind.push((i*10+j)*4+3);

			}
		}

		var structure = new VertexStructure();
        structure.add("pos", VertexData.Float3);
        
        pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		pipeline.fragmentShader = Shaders.simple_frag;
		pipeline.vertexShader = Shaders.simple_vert;
		pipeline.compile();

		vertexBuffer = new VertexBuffer(
			Std.int(v.length / 3), // Vertex count - 3 floats per vertex
			structure, // Vertex structure
			Usage.StaticUsage // Vertex data will stay the same
		);
		
		var vbData = vertexBuffer.lock();
		for (i in 0...vbData.length) {
			vbData.set(i, v[i]);
		}
		vertexBuffer.unlock();

		indexBuffer = new IndexBuffer(
			ind.length, // 3 indices for our triangle
			Usage.StaticUsage // Index data will stay the same
		);
		
		var iData = indexBuffer.lock();
		for (i in 0...iData.length) {
			iData[i] = ind[i];
		}
		indexBuffer.unlock();
    }

	public function render(frame:Framebuffer) {
		var g = frame.g4;
	    g.begin();
		g.clear(Color.Black);
		g.setPipeline(pipeline);
		g.setVertexBuffer(vertexBuffer);
		g.setIndexBuffer(indexBuffer);
		g.drawIndexedVertices();
		g.end();
    }
}
