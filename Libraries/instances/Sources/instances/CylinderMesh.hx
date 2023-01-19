package instances;
/*The MIT License (MIT)
Copyright (c) 2016 Christian Reuter
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.*/
import kha.math.Matrix3;
import kha.math.Vector2;

// Generates index and vertex data for a cylinder
class CylinderMesh {
	
	public var vertices: Array<Float>;
	public var indices: Array<Int>;
	
	public function new(sections : Int) {
		// Radius
		var r : Float = 0.5;
		// Height
		var h : Float = 1;
		
		vertices = new Array<Float>();
		indices = new Array<Int>();
		
		// Bottom center
		vertices.push(0);
		vertices.push(0);
		vertices.push(0);
		
		// Top center
		vertices.push(0);
		vertices.push(h);
		vertices.push(0);
		
		var index : Int = 2;
		var firstPoint : Vector2 = new Vector2(0, r);
		var lastPoint : Vector2 = firstPoint;
		var nextPoint : Vector2;
		for (i in 0...sections) {
			nextPoint = Matrix3.rotation(i * (2 / sections) * Math.PI).multvec(firstPoint);
			
			addSection(lastPoint, nextPoint, h, index);
			
			lastPoint = nextPoint;
			index += 4;
		}
		
		addSection(lastPoint, firstPoint, h, index);
		
	}
	
	private function addSection(lastPoint : Vector2, nextPoint : Vector2, h : Float, index : Int) {
		vertices.push(lastPoint.x);
		vertices.push(0);
		vertices.push(lastPoint.y);
		
		vertices.push(lastPoint.x);
		vertices.push(h);
		vertices.push(lastPoint.y);
		
		vertices.push(nextPoint.x);
		vertices.push(0);
		vertices.push(nextPoint.y);
		
		vertices.push(nextPoint.x);
		vertices.push(h);
		vertices.push(nextPoint.y);
		
		// First part of side
		indices.push(index);
		indices.push(index + 1);
		indices.push(index + 2);
		
		// Second part of side
		indices.push(index + 3);
		indices.push(index + 2);
		indices.push(index + 1);
		
		// Bottom
		indices.push(0);
		indices.push(index);
		indices.push(index + 2);
		
		// Top
		indices.push(index + 3);
		indices.push(index + 1);
		indices.push(1);
	}
}