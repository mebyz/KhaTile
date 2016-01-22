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
import kha.graphics4.ConstantLocation;
import kha.math.FastMatrix4;
import kha.math.FastVector3;

class PlaneInstance {

	var vertexBuffer:VertexBuffer;
	var indexBuffer:IndexBuffer;
	var pipeline:PipelineState;

	var mvp:FastMatrix4;
	var mvpID:ConstantLocation;

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
		pipeline.depthWrite = true;
        pipeline.depthMode = CompareMode.Less;
		pipeline.compile();

		mvpID = pipeline.getConstantLocation("MVP");

		var projection = FastMatrix4.perspectiveProjection(45.0, 4.0 / 3.0, 0.1, 100.0);
		
		var view = FastMatrix4.lookAt(new FastVector3(4, 3, 3), // Camera at (4, 3, 3)
								  new FastVector3(0, 0, 0), //  look at origin
								  new FastVector3(0, 1, 0) // Head is up, set (0, -1, 0) to look upside down
		);

		var model = FastMatrix4.identity();
		mvp = FastMatrix4.identity();
		mvp = mvp.multmat(projection);
		mvp = mvp.multmat(view);
		mvp = mvp.multmat(model);

		vertexBuffer = new VertexBuffer(
			Std.int(v.length / 3), // 3 floats per vertex
			structure, 
			Usage.StaticUsage 
		);
		
		var vbData = vertexBuffer.lock();
		for (i in 0...vbData.length) {
			vbData.set(i, v[i]);
		}
		vertexBuffer.unlock();

		indexBuffer = new IndexBuffer(
			ind.length, 
			Usage.StaticUsage 
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
		g.setMatrix(mvpID, mvp);
		g.drawIndexedVertices();
		g.end();
    }
}
