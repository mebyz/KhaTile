package primitive;

import js.lib.Float32Array;
import js.lib.ArrayBuffer;
import kha.audio2.Buffer;
import kha.SystemImpl;
import js.html.webgl.GL2;
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

class TerrainModel {

	static inline var REPEAT : Int = 10497;
	static inline var TEXTURE_WRAP_S : Int = 10242;
	static inline var TEXTURE_WRAP_T : Int = 10243;
	static inline var TEXTURE_2D : Int = 3553;

	public var st:VertexStructure;
	public var vtb:VertexBuffer;
	public var idb:IndexBuffer;
	public var pipeline:PipelineState;
	public var mvpID:ConstantLocation;
	public var shader : Dynamic;

	public function new(heightmap :Array<Int>, normalMap : Array<Vec3>, idx,idy, params : Dynamic) {

		var va = new Float32Array(normalMap.length*3);

		var wb = SystemImpl.gl.createBuffer();
		SystemImpl.gl.bindBuffer(34962 /*SystemImpl.gl.ARRAY_BUFFER*/, wb);


		for(i in 0...normalMap.length){
			
			va[i*3]=normalMap[i].x;
			va[i*3+1]=normalMap[i].y;
			va[i*3+2]=normalMap[i].z;
		} 

		SystemImpl.gl.bufferData(
			34962,
			va,
			35044); //STATIC_DRAW);

		var shader = {f:Shaders.simple_frag,v:Shaders.simple_vert};

		var pr = new Primitive('heightmap', {w:params.w,h: params.h,x: params.x,y: params.y,heights:heightmap,idx:idx,idy:idy});
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

		var numComponents = 3;
		var type = 5126; // SystemImpl.gl.FLOAT;
		var normalize = false;
		var stride = 0;
		var offset = 0;
	  	SystemImpl.gl.bindBuffer(34962 /*SystemImpl.gl.ARRAY_BUFFER*/, wb);

		SystemImpl.gl.bindAttribLocation(pipeline.program, 0, "vertexNormal");
		SystemImpl.gl.vertexAttribPointer(
		0,
		  numComponents,
		  type,
		  normalize,
		  stride,
		  offset
		);
		SystemImpl.gl.enableVertexAttribArray(0);
		
	}
	public function drawPlane(frame:Framebuffer, mvp:FastMatrix4) {	
		var g = frame.g4;
		g.setPipeline(pipeline);
		g.setVertexBuffer(vtb);
		g.setIndexBuffer(idb);
		
		// Get a handle for texture sample
		var sand = pipeline.getTextureUnit("sand");
		var image = Assets.images.sand;
		g.setTexture(sand, image);
		var stone = pipeline.getTextureUnit("stone");
		var image2 = Assets.images.stone;
		g.setTexture(stone, image2);
		var grass = pipeline.getTextureUnit("grass");
		var image3 = Assets.images.grass;
		g.setTexture(grass, image3);
		var snow = pipeline.getTextureUnit("snow");
		var image4 = Assets.images.snow;
		g.setTexture(snow, image4);
		g.setMatrix(mvpID, mvp);
		
		
		kha.SystemImpl.gl.texParameteri(TEXTURE_2D, TEXTURE_WRAP_S, REPEAT);
		kha.SystemImpl.gl.texParameteri(TEXTURE_2D, TEXTURE_WRAP_T, REPEAT);
		
		g.drawIndexedVertices();
	}
}
