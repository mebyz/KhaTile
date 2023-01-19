package instances;

import kha.Framebuffer;
import kha.Color;
import kha.graphics4.CullMode;
import kha.math.Random;
import kha.math.Vector3;
import kha.math.Vector4;
import kha.Scheduler;
import kha.Shaders;
import kha.Assets;
import kha.graphics4.ConstantLocation;
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
import kha.math.FastMatrix4;
import kha.math.FastVector3;

class Instances {

	static var instancesX : Int = 100;
	static var instancesZ : Int = 100;

	var cameraStart : Vector4;
	var model : FastMatrix4;
	var view : FastMatrix4;
	var projection : FastMatrix4;
	var mvp : FastMatrix4;
	var mvp2 : FastMatrix4;
	
	var mvpID:ConstantLocation;

	var ins : Array<Dynamic>;
	
	var vertexBuffers: Array<VertexBuffer>;
	var indexBuffer: IndexBuffer;
	var pipeline: PipelineState;



	public function createInstances(type : String, iX = 100, iZ = 100) {
		Random.init(Std.random(403));
		instancesX = iX;
		instancesZ = iZ;
		// Initialize data, not relevant for rendering
		ins = new Array<Dynamic>();
		for (x in 0...instancesX) {
			for (z in 0...instancesZ) {
				// Span x/z grid, center on 0/0
				var pos = new Vector3(x - (instancesX - 1) / 2, 0, z - (instancesZ - 1) / 2);
				switch (type) {
					case 'cylinder':
						ins.push(new Cylinder(pos));
					case 'grass' :
						ins.push(new GrassPatch(pos));
				}
			}
		}
	}

	public function createMesh(type : String) : Dynamic {
		return switch (type) {
			case 'cylinder': new CylinderMesh(32);
			case 'grass' : new GrassMesh();
			case _: null;
		}
	}

	public function setupPipeline(structures : Array<VertexStructure>, f : Dynamic, v : Dynamic) {
	
		// Setup pipeline
		pipeline = new PipelineState();
		pipeline.fragmentShader = f;
		pipeline.vertexShader = v;
		pipeline.inputLayout = structures;
		pipeline.depthWrite = true;
		pipeline.depthMode = CompareMode.Less;
		pipeline.cullMode = CullMode.CounterClockwise;
		pipeline.compile();	

	}

	public function fillStructure(mesh : Dynamic) :  Array<VertexStructure> {
	
		var structures = new Array<VertexStructure>();
		
		structures[0] = new VertexStructure();
        structures[0].add("pos", VertexData.Float3);
		
		// Vertex buffer
		vertexBuffers = new Array();
		vertexBuffers[0] = new VertexBuffer(
			Std.int(mesh.vertices.length / 3),
			structures[0],
			Usage.StaticUsage
		);
		
		var vbData = vertexBuffers[0].lock();
		for (i in 0...vbData.length) {
			vbData.set(i, mesh.vertices[i]);
		}
		vertexBuffers[0].unlock();
		
		// Index buffer
		indexBuffer = new IndexBuffer(
			mesh.indices.length,
			Usage.StaticUsage
		);
		
		var iData = indexBuffer.lock();
		for (i in 0...iData.length) {
			iData[i] = mesh.indices[i];
		}
		indexBuffer.unlock();
		
		// Color structure, is different for each instance
		structures[1] = new VertexStructure();
        structures[1].add("col", VertexData.Float3);
		
		vertexBuffers[1] = new VertexBuffer(
			ins.length,
			structures[1],
			Usage.StaticUsage,
			1 // changed after every instance, use i higher number for repetitions
		);
		
		var oData = vertexBuffers[1].lock();
		for (i in 0...ins.length) {
			oData.set(i * 3, 1);
			oData.set(i * 3 + 1, 0.75 + Random.getIn(-100, 100) / 500);
			oData.set(i * 3 + 2, 0);
		}
		vertexBuffers[1].unlock();
		
		// Transformation matrix, is different for each instance
		structures[2] = new VertexStructure();
		structures[2].add("m", VertexData.Float4x4);
		vertexBuffers[2] = new VertexBuffer(
			ins.length,
			structures[2],
			Usage.StaticUsage,
			1 
		);
		return structures;
	}


	public function fillStructure2(mesh : Dynamic) :  Array<VertexStructure> {
	

		var structures = new Array<VertexStructure>();
			
		structures[0] = new VertexStructure();
        structures[0].add("pos", VertexData.Float3);
        structures[0].add("uv", VertexData.Float2);
        structures[0].add("nor", VertexData.Float3);
        // Save length - we store position, uv and normal data
        var structureLength = 8;


	
		// Vertex buffer
		vertexBuffers = new Array();
		vertexBuffers[0] = new VertexBuffer(
			Std.int(mesh.vertices.length / structureLength),
			structures[0],
			Usage.StaticUsage
		);
		
		var vbData = vertexBuffers[0].lock();
		for (i in 0...vbData.length) {
			vbData.set(i, mesh.vertices[i]);
		}
		vertexBuffers[0].unlock();
		
		// Index buffer
		indexBuffer = new IndexBuffer(
			mesh.indices.length,
			Usage.StaticUsage
		);
		
		var iData = indexBuffer.lock();
		for (i in 0...iData.length) {
			iData[i] = mesh.indices[i];
		}
		indexBuffer.unlock();
		
		// Color structure, is different for each instance
		structures[1] = new VertexStructure();
        structures[1].add("col", VertexData.Float3);
		
		vertexBuffers[1] = new VertexBuffer(
			ins.length,
			structures[1],
			Usage.StaticUsage,
			1 // changed after every instance, use i higher number for repetitions
		);
		
		var oData = vertexBuffers[1].lock();
		for (i in 0...ins.length) {
			oData.set(i * 3, 0.3);
			oData.set(i * 3 + 1, 0.75 + Random.getIn(-100, 100) / 500);
			oData.set(i * 3 + 2, 0.3);
		}
		vertexBuffers[1].unlock();
		
		// Transformation matrix, is different for each instance
		structures[2] = new VertexStructure();
		structures[2].add("m", VertexData.Float4x4);
		vertexBuffers[2] = new VertexBuffer(
			ins.length,
			structures[2],
			Usage.StaticUsage,
			1 
		);

		return structures;
	}
	public function new(type : String, iX = 100, iZ = 100, m = null, vv= null, p = null, imvp = null) {

		createInstances(type, iX, iZ);


		cameraStart = new Vector4(0, 5, 10);
		if (p != null)
			projection = p;
		else
			projection = FastMatrix4.perspectiveProjection(45.0, 4.0 / 3.0, 0.1, 100.0);
		
		var mesh:Dynamic = createMesh(type);
		
		
		switch (type) {
			case 'cylinder': {
				var f =  Shaders.cylinder_frag;
				var v = Shaders.cylinder_vert;				
				var structures = fillStructure(mesh);
				setupPipeline(structures, f, v);
			}
			case 'grass': {
				var f =  Shaders.cylinder_frag;
				var v = Shaders.cylinder_vert;				
				var structures = fillStructure2(mesh);
				setupPipeline(structures, f, v);
				//mvpID = pipeline.getConstantLocation("MVP");

				var model = null;
				if (m !=null)
					model= m;
				else
					model = FastMatrix4.identity();

				if (vv !=null)
					view= vv;

				mvp2 = FastMatrix4.identity();
				if (projection !=null)
					mvp2 = mvp2.multmat(projection);
				if (view !=null)
					mvp2 = mvp2.multmat(view);
				if (model !=null)
					mvp2 = mvp2.multmat(model);

			}
			case _: null;
		}

	}

	public function render(frame : Framebuffer,m,v,p) {
		
		var g = frame.g4;
		
		var vp = FastMatrix4.identity();
		vp = vp.multmat(p);
		vp = vp.multmat(v);

		mvp2 = FastMatrix4.identity();
					mvp2 = mvp2.multmat(p);
					mvp2 = mvp2.multmat(v);
					mvp2 = mvp2.multmat(m);

		// Fill transformation matrix buffer with values from each instance
		var mData = vertexBuffers[2].lock();
		for (i in 0...ins.length) {
			mvp = vp.multmat(ins[i].getModelMatrix());
			
			mData.set(i * 16 + 0, mvp._00);		
			mData.set(i * 16 + 1, mvp._01);		
			mData.set(i * 16 + 2, mvp._02);		
			mData.set(i * 16 + 3, mvp._03);		
			
			mData.set(i * 16 + 4, mvp._10);		
			mData.set(i * 16 + 5, mvp._11);		
			mData.set(i * 16 + 6, mvp._12);		
			mData.set(i * 16 + 7, mvp._13);		
			
			mData.set(i * 16 + 8, mvp._20);		
			mData.set(i * 16 + 9, mvp._21);		
			mData.set(i * 16 + 10, mvp._22);		
			mData.set(i * 16 + 11, mvp._23);		
			
			mData.set(i * 16 + 12, mvp._30);		
			mData.set(i * 16 + 13, mvp._31);		
			mData.set(i * 16 + 14, mvp._32);		
			mData.set(i * 16 + 15, mvp._33);		
		}		
		vertexBuffers[2].unlock();
		
        //g.begin();
		//g.clear(Color.fromFloats(0, 0, 0));
		g.setPipeline(pipeline);
		
		// Instanced rendering
		if (mvpID!=null) {
			g.setVertexBuffers(vertexBuffers);
			g.setIndexBuffer(indexBuffer);
			g.setMatrix(mvpID, mvp2);
			g.drawIndexedVerticesInstanced(ins.length);
		}
		
		g.end();			
	}

	public function updateAll() {
		for (i in 0...ins.length) {
			ins[i].update();
		}
	}
}