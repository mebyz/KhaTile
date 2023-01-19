package primitive;

import kha.Assets;
import kha.graphics4.IndexBuffer;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexData;

class Shape {

	var vertexBuffer:VertexBuffer;
	var indexBuffer:IndexBuffer;
	var uvsBuffer:Array<Float>;

	public function new() {
		  Assets.loadEverything(function(){});
	}

	public function getIndexBuffer() {
		return indexBuffer;
	}

	public function getUvsBuffer() {
		return uvsBuffer;
	}

	public function getVertexBuffer() {
		return vertexBuffer;
	}
	
	public function getVertexStructure() {
		var structure = new VertexStructure();
        structure.add("pos", VertexData.Float3);
        structure.add("uv", VertexData.Float2);
        return structure;
    }
}