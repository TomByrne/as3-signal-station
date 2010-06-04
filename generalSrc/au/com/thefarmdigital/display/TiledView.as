package au.com.thefarmdigital.display
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class TiledView extends View
	{
		
		public function get tileClass():Class{
			return _tileClass;
		}
		public function set tileClass(value:Class):void{
			if(_tileClass!=value){
				_tileClass = value;
				invalidateMeasurements();
				clearTiles();
				invalidate();
			}
		}
		
		public function get tileSize():Point{
			return _tileSize;
		}
		public function set tileSize(value:Point):void{
			if(_tileSize!=value){
				_tileSize = value;
				invalidate();
			}
		}
		
		public function get maskContents():Boolean{
			return _maskContents;
		}
		public function set maskContents(value:Boolean):void{
			if(_maskContents!=value){
				_maskContents = value;
				invalidate();
			}
		}
		
		private var _maskContents:Boolean = true;
		private var _tileSize:Point;
		private var _implicitTileSize:Point;
		private var _tileClass:Class;
		private var _tiles:Array = [];
		
		public function TiledView(tileClass:Class=null){
			super();
			this.tileClass = tileClass;
			
		}
		protected function clearTiles():void{
			for each(var display:DisplayObject in _tiles){
				removeChild(display);
			}
			_tiles = [];
		}
		protected function getTileSize():Point{
			if(!_implicitTileSize){
				var proto:DisplayObject = new _tileClass();
				_implicitTileSize = new Point(proto.width, proto.height);
			}
			return _implicitTileSize;
		}
		override protected function measure():void{
			var size:Point = getTileSize();
			_measuredWidth = size.x;
			_measuredHeight = size.y;
		}
		override protected function draw():void{
			var index:int = 0;
			if(_tileClass){
				var dimensions:Point = (_tileSize?_tileSize:getTileSize());
				var yStack:Number = 0;
				var totalY:int = (height/dimensions.y)+1;
				var totalX:int = (width/dimensions.x)+1;
				for(var y:int=0; y<totalY; y++){
					var xStack:Number = 0;
					for(var x:int=0; x<totalX; x++){
						index = (y*totalX)+x;
						var tile:DisplayObject = _tiles[index];
						if(!tile){
							 tile = _tiles[index] = new _tileClass();
							 addChild(tile);
						}
						tile.y = yStack;
						tile.x = xStack;
						xStack += dimensions.x;
					}
					yStack += dimensions.y;
				}
				_tiles.splice(max,_tiles.length-max);
			}
			var max:int = index+1;
			for(; index<_tiles.length; index++){
				removeChild(_tiles[index]);
			}
			if(_maskContents){
				scrollRect = new Rectangle(0,0,width,height);
			}else{
				scrollRect = null;
			}
		}
	}
}