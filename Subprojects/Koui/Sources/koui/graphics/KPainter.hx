package koui.graphics;

import haxe.ds.Vector;

import kha.Canvas;
import kha.FastFloat;
import kha.arrays.Float32Array;
import kha.graphics4.ConstantLocation;
import kha.graphics4.FragmentShader;
import kha.graphics4.Graphics;
import kha.graphics4.Graphics2.PipelineCache;
import kha.graphics4.Graphics2.SimplePipelineCache;
import kha.graphics4.IndexBuffer;
import kha.graphics4.PipelineState;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;

import koui.Koui;

using StringTools;

class KPainter {
	#if (KOUI_EFFECTS_OFF || KOUI_EFFECTS_SHADOW_OFF)
	public function new(g4: kha.graphics4.Graphics, uniformNames: Array<String>) {}
	private static inline override function init() {}
	#else

	public var g4: Graphics;
	public var pipelineCache: PipelineCache;
	var canvas: Canvas;
	var pipeline: PipelineState;
	var vert: VertexShader;
	var frag: FragmentShader;
	var indexBuffer: IndexBuffer;
	var vertexBuffers: Array<VertexBuffer>;
	var structures: Array<VertexStructure>;
	var structureLengths: Vector<Int>;
	// vertexBuffer contents
	var vCoords: Float32Array;
	var vColors: Float32Array;

	/** Max number of quads to draw in one drawcall. **/
	static final bufferSize = 16;
	var bufferIndex = 0;

	// Uniforms
	var uniformNames: Array<String> = [];
	var bindConstants: Map<String, ConstantLocation>;
	var uniformValues: Map<String, Float32Array>;

	public function new(g4: kha.graphics4.Graphics, canvas: Canvas,
			uniformNames: Array<String>, vert: VertexShader, frag: FragmentShader) {
		this.g4 = g4;
		this.canvas = canvas;
		this.uniformNames = uniformNames;
		this.vert = vert;
		this.frag = frag;
	}

	public function init() {
		bufferIndex = 0;

		uniformValues = new Map();
		for (uniformName in uniformNames) {
			// All uniforms are currently vec4 arrays
			uniformValues[uniformName] = new Float32Array(bufferSize * 4);
		}

		if (structures == null) {
			initVertexStructures();
		}
		if (indexBuffer == null || vertexBuffers == null) {
			initBuffers();
		}
		if (pipeline == null) {
			initPipeline();
		}
	}

	function initVertexStructures() {
		structures = new Array();
		structureLengths = new Vector(2);

		// Vertex position
		structures[0] = new VertexStructure();
		structures[0].add("pos", VertexData.Float3);
		// if (g4.instancedRenderingAvailable()) structures[0].instanced = true;

		// Vertex color
		structures[1] = new VertexStructure();
		structures[1].add("col", VertexData.Float4);
		// if (g4.instancedRenderingAvailable()) structures[1].instanced = true;

		structureLengths[0] = 3;
		structureLengths[1] = 4;
	}

	function initPipeline() {
		pipeline = new PipelineState();
		pipeline.inputLayout = structures;
		pipeline.vertexShader = vert;
		pipeline.fragmentShader = frag;

		pipeline.blendSource = SourceAlpha;
		pipeline.blendDestination = InverseSourceAlpha;
		pipeline.blendOperation = Add;
		pipeline.alphaBlendOperation = Add;
		pipeline.alphaBlendSource = BlendOne;
		pipeline.alphaBlendDestination = InverseSourceAlpha;
		pipeline.cullMode = None;

		pipeline.compile();

		pipelineCache = new SimplePipelineCache(pipeline, false);

		bindConstants = new Map();
		for (uniformName in uniformNames) {
			bindConstants[uniformName] = pipeline.getConstantLocation(uniformName);
		}
	}

	function initBuffers() {
		vertexBuffers = new Array();

		final maxNumVerts = bufferSize * 4;
		vertexBuffers[0] = new VertexBuffer(maxNumVerts, structures[0], Usage.DynamicUsage);
		vertexBuffers[1] = new VertexBuffer(maxNumVerts, structures[1], Usage.DynamicUsage);
		vCoords = new Float32Array(maxNumVerts * structureLengths[0]);
		vColors = new Float32Array(maxNumVerts * structureLengths[1]);

		var indices = [0, 1, 2, 1, 2, 3];
		var indicesLength = indices.length;

		indexBuffer = new IndexBuffer(bufferSize * indicesLength, Usage.StaticUsage);
		var ibuffer = indexBuffer.lock();
		for (i in 0...bufferSize) {
			for (j in 0...indicesLength) {
				ibuffer[i * indicesLength + j] = i * 4 + indices[j]; // 4 = Quad
			}
		}
		indexBuffer.unlock();
	}

	inline function setRectVertices(left: FastFloat, right: FastFloat, top: FastFloat, bottom: FastFloat) {
		var quadIndex = bufferIndex * structureLengths[0] * 4; // 4 vertices

		vCoords.set(quadIndex + 0, left);
		vCoords.set(quadIndex + 1, top);
		// Hack: use z coordinate as instanceID because we don't use instanced
		// rendering
		vCoords.set(quadIndex + 2, bufferIndex);

		vCoords.set(quadIndex + 3, left);
		vCoords.set(quadIndex + 4, bottom);
		vCoords.set(quadIndex + 5, bufferIndex);

		vCoords.set(quadIndex + 6, right);
		vCoords.set(quadIndex + 7, top);
		vCoords.set(quadIndex + 8, bufferIndex);

		vCoords.set(quadIndex + 9, right);
		vCoords.set(quadIndex + 10, bottom);
		vCoords.set(quadIndex + 11, bufferIndex);
	}

	inline function setRectColors(direction: Bool, colorTopLeft: kha.Color, colorBottomRight: kha.Color, opacity: FastFloat) {
		var colorTL: kha.Color;
		var colorTR: kha.Color;
		var colorBL: kha.Color;
		var colorBR: kha.Color;

		// Top->Down
		if (direction) {
			colorTL = colorTopLeft;
			colorTR = colorTopLeft;
			colorBL = colorBottomRight;
			colorBR = colorBottomRight;
		}
		// Left->Right
		else {
			colorTL = colorTopLeft;
			colorTR = colorBottomRight;
			colorBL = colorTopLeft;
			colorBR = colorBottomRight;
		}

		var quadIndex = bufferIndex * structureLengths[1] * 4;

		vColors.set(quadIndex + 0, colorTL.R);
		vColors.set(quadIndex + 1, colorTL.G);
		vColors.set(quadIndex + 2, colorTL.B);
		vColors.set(quadIndex + 3, colorTL.A * opacity);

		vColors.set(quadIndex + 4, colorBL.R);
		vColors.set(quadIndex + 5, colorBL.G);
		vColors.set(quadIndex + 6, colorBL.B);
		vColors.set(quadIndex + 7, colorBL.A * opacity);

		vColors.set(quadIndex + 8, colorTR.R);
		vColors.set(quadIndex + 9, colorTR.G);
		vColors.set(quadIndex + 10, colorTR.B);
		vColors.set(quadIndex + 11, colorTR.A * opacity);

		vColors.set(quadIndex + 12, colorBR.R);
		vColors.set(quadIndex + 13, colorBR.G);
		vColors.set(quadIndex + 14, colorBR.B);
		vColors.set(quadIndex + 15, colorBR.A * opacity);
	}

	function drawBuffer() {
		var vbCoords = vertexBuffers[0].lock();
		for (i in 0...vCoords.length) {
			vbCoords.set(i, vCoords[i]);
		}
		vertexBuffers[0].unlock();
		var vbColors = vertexBuffers[1].lock();
		for (i in 0...vColors.length) {
			vbColors.set(i, vColors[i]);
		}
		vertexBuffers[1].unlock();

		g4.setPipeline(pipeline);
		g4.setIndexBuffer(indexBuffer);
		g4.setVertexBuffers(vertexBuffers);

		for (uniformName in uniformNames) {
			g4.setFloats(bindConstants[uniformName], uniformValues[uniformName]);
		}

		// if (g4.instancedRenderingAvailable()) {
		// 	// 6 = 2 * 3 vertices
		// 	g4.drawIndexedVerticesInstanced(bufferIndex, 0, bufferIndex * 6);
		// } else {
		g4.drawIndexedVertices(0, bufferIndex * 6);

		#if KOUI_DEBUG_DRAWINGTIME
		Koui.numDrawCalls++;
		Koui.bufferSizes.push(bufferIndex);
		#end
		// }

		bufferIndex = 0;
	}

	public function end() {
		if (bufferIndex > 0) drawBuffer();
	}
	#end
}
