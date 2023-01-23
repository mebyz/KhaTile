package primitive;

import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;
import kha.graphics4.PipelineState;
import kha.graphics4.ConstantLocation;
import kha.Framebuffer;
import kha.math.FastMatrix4;
import kha.graphics4.CompareMode;
import kha.Shaders;
import kha.Assets;

class SkyCubeModel {

	public var st:VertexStructure;
	public var vtb:VertexBuffer;
	public var idb:IndexBuffer;
	public var pipeline:PipelineState;
	public var mvpID:ConstantLocation;
	public var shader : Dynamic;

	public function new(x: Int, y: Int, z: Int, params : Dynamic) {

		var shader = {f:Shaders.sky_frag,v:Shaders.sky_vert};

		var pr = new Primitive('cube', {x:x,y:y,z:z});
		st  = pr.getVertexStructure();
		idb = pr.getIndexBuffer();
		vtb = pr.getVertexBuffer();

        pipeline = new PipelineState();
		pipeline.inputLayout = [st];

		pipeline.fragmentShader = shader.f;
		pipeline.vertexShader = shader.v;
		pipeline.depthWrite = true;
        pipeline.depthMode = CompareMode.Less;
		pipeline.compile();

		mvpID = pipeline.getConstantLocation("MVP");
	}
	public function draw(frame:Framebuffer, mvp:FastMatrix4) {	
		var g = frame.g4;
		g.setPipeline(pipeline);
		g.setVertexBuffer(vtb);
		g.setIndexBuffer(idb);

		// Get a handle for texture sample
		var skyTexture = pipeline.getTextureUnit("sky");
		var image = Assets.images.sky;
		g.setTexture(skyTexture, image);
		
		g.setMatrix(mvpID, mvp);
		g.drawIndexedVertices();
	}
}
