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
import primitive.Primitive;

class PlaneInstance {

	var st:VertexStructure;
	var vtb:VertexBuffer;
	var idb:IndexBuffer;
	var pipeline:PipelineState;

	var mvp:FastMatrix4;
	var mvpID:ConstantLocation;

	public function new() {

		var pr = new Primitive('plane', { size : 20 });
		var pr = new Primitive('cube', { x : 1,y : 1,z : 1 });

		st = pr.getVertexStructure();
		idb = pr.getIndexBuffer();
		vtb = pr.getVertexBuffer();
        

        pipeline = new PipelineState();
		pipeline.inputLayout = [st];
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

    }

	public function render(frame:Framebuffer) {
		var g = frame.g4;
	    g.begin();
		g.clear(Color.Black);
		g.setPipeline(pipeline);
		g.setVertexBuffer(vtb);
		g.setIndexBuffer(idb);
		g.setMatrix(mvpID, mvp);
		g.drawIndexedVertices();
		g.end();
    }
}
