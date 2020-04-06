package  {
	import flash.display.BitmapData;
	
	public class BlitTexture {
		
		private var x:int;
		private var y:int;
		private var w:int;
		private var h:int;
		private var texture:BitmapData;
		
		public function BlitTexture(col:int, row:int, size:int, _texture:BitmapData) {
			x = col * size;
			y = row* size;
			w = size;
			h = size;
			texture = _texture;
		}
		
		public function getPixel(_xPer:Number, _yPer:Number):uint{
			return texture.getPixel(int(_xPer * w) + x, int(_yPer * h) + y);
		}
		
		public function get width():int
		{
			return w;
		}
		
		public function get height():int
		{
			return h;
		}

	}
	
}
