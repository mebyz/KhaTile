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
import noisetile.NoiseTile;

class PlaneInstance {

	var planes : Array<PlaneModel>;
	var mvp:FastMatrix4;

	public function new() {

		var gridSize = 10;

		var nt : Dynamic= new NoiseTile(10,10,16);

		planes = new Array();

		for (j in 0...gridSize)
			for (i in 0...gridSize)
				planes.push(new PlaneModel(nt.t.tiles[i+j*gridSize],i,j));

		var projection = FastMatrix4.perspectiveProjection(45.0, 4.0 / 3.0, 0.1, 1000.0);
		
		var view = FastMatrix4.lookAt(new FastVector3(100, 150, 100), // Camera at (4, 3, 3)
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
		/////
		/////
		for (plane in planes)
			plane.drawPlane(frame,mvp);
		/////
		/////
		g.end();
    }
}

class PlaneModel {

	public var st:VertexStructure;
	public var vtb:VertexBuffer;
	public var idb:IndexBuffer;
	public var pipeline:PipelineState;
	public var mvpID:ConstantLocation;
	public var shaders : Dynamic;
	public var shader1 : Dynamic;
	public var shader2 : Dynamic;

	public function new(heightmap :Array<Int>,idx,idy) {

		var shader1 = {f:Shaders.simple_frag,v:Shaders.simple_vert};
		var shader2 = {f:Shaders.green_frag,v:Shaders.green_vert};
		var shaders = [shader1,shader2];

		var pr = new Primitive('heightmap', { w:16, h:16, x:16, y:16, heights:heightmap,idx:idx,idy:idy});
		st  = pr.getVertexStructure();
		idb = pr.getIndexBuffer();
		vtb = pr.getVertexBuffer();

        pipeline = new PipelineState();
		pipeline.inputLayout = [st];

		pipeline.fragmentShader = shaders[(idx+idy*10+idy*3)%2].f;
		pipeline.vertexShader = shaders[(idx+idy*10+idy*3)%2].v;
		pipeline.depthWrite = true;
        pipeline.depthMode = CompareMode.Less;
		pipeline.compile();

		mvpID = pipeline.getConstantLocation("MVP");
	}
	public function drawPlane(frame:Framebuffer, mvp:FastMatrix4) {	
		var g = frame.g4;
		g.setPipeline(pipeline);
		g.setVertexBuffer(vtb);
		g.setIndexBuffer(idb);
		g.setMatrix(mvpID, mvp);
		g.drawIndexedVertices();
	}
}