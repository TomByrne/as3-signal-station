package org.farmcode.debug.display
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.xml.XMLNode;
	
	import org.farmcode.acting.acts.Act;
	import org.farmcode.core.EnterFrameHook;
	import org.farmcode.data.dataTypes.INumberProvider;
	import org.farmcode.display.assets.AssetNames;
	import org.farmcode.display.assets.assetTypes.IBitmapAsset;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.controls.Button;
	import org.farmcode.display.controls.TextLabelButton;
	import org.farmcode.display.core.LayoutView;
	import org.farmcode.display.layout.list.ListLayout;
	import org.farmcode.display.layout.list.ListLayoutInfo;

	public class DebugGraph extends LayoutView
	{
		
		public function get backgroundColour():Number{
			return _backgroundColour;
		}
		public function set backgroundColour(value:Number):void{
			if(_backgroundColour!=value){
				_backgroundColour = value;
				redrawAll(true);
			}
		}
		
		
		public function get gridColour():Number{
			return _gridColour;
		}
		public function set gridColour(value:Number):void{
			if(_gridColour!=value){
				_gridColour = value;
			}
		}
		
		
		public function get framesPerGrid():int{
			return _framesPerGrid;
		}
		public function set framesPerGrid(value:int):void{
			if(_framesPerGrid!=value){
				_framesPerGrid = value;
			}
		}
		
		public function get framesPerPixel():int{
			return _framesPerPixel;
		}
		public function set framesPerPixel(value:int):void{
			if(_framesPerPixel!=value){
				_framesPerPixel = value;
				redrawAll(true);
			}
		}
		
		/**
		 * Amount of padding from the top before the maximum line. This is a fraction of the height.
		 */
		public function get maxPadding():Number{
			return _maxPadding;
		}
		public function set maxPadding(value:Number):void{
			if(_maxPadding!=value){
				_maxPadding = value;
				redrawAll(true);
			}
		}
		
		private var _bitmap:IBitmapAsset;
		private var _copyButton:TextLabelButton;
		private var _stackLayout:ListLayout;
		
		private var _maxPadding:Number = 0.1;
		private var _statId:int = 0;
		private var _framesPerGrid:int = 20;
		private var _framesPerPixel:int = 1;
		private var _gridColour:Number = 0x222222;
		private var _backgroundColour:Number = 0;
		protected var _displayChanged:Act;
		private var _bitmapData:BitmapData;
		private var _frames:Vector.<FrameRecord> = new Vector.<FrameRecord>();
		private var _statistics:Vector.<StatisticInfo> = new Vector.<StatisticInfo>();
		private var _fillRect:Rectangle = new Rectangle();
		private var _maxRect:Rectangle = new Rectangle();
		
		public function DebugGraph(width:int, height:int){
			setSize(width,height);
			EnterFrameHook.getAct().addHandler(onEnterFrame);
		}
		override protected function init() : void{
			super.init();
			_stackLayout = new ListLayout(this);
			_stackLayout.margin = 2;
			_stackLayout.gap = 2;
			_copyButton = new TextLabelButton();
			_copyButton.layoutInfo = new ListLayoutInfo(0);
			_copyButton.clicked.addHandler(onCopyClicked);
			_stackLayout.addSubject(_copyButton);
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			CONFIG::debug{
				_bitmap = _containerAsset.takeAssetByName(AssetNames.DEBUG_ITEM_BITMAP,IBitmapAsset);
				_bitmap.bitmapData = _bitmapData;
				
				_copyButton.asset = _containerAsset.takeAssetByName(AssetNames.DEBUG_GRAPH_COPY_BUTTON,IDisplayAsset);
			}
		}
		override protected function unbindFromAsset() : void{
			_bitmap.bitmapData = null;
			_containerAsset.returnAsset(_bitmap);
			_containerAsset.returnAsset(_copyButton.asset);
			super.unbindFromAsset();
		}
		override protected function measure() : void{
			if(_bitmapData){
				_measurements.x = _bitmapData.width;
				_measurements.y = _bitmapData.height;
			}
			var stackMeas:Point = _stackLayout.measurements;
			_measurements.y += stackMeas.y;
			if(_measurements.x<stackMeas.x){
				_measurements.x = stackMeas.x;
			}
		}
		override protected function draw() : void{
			super.draw();
			var pos:Rectangle = displayPosition;
			var stackMeas:Point = _stackLayout.measurements;
			_bitmap.setSizeAndPos(0,0,pos.width,pos.height-stackMeas.y);
			_stackLayout.setDisplayPosition(0,pos.height-stackMeas.y,pos.width,stackMeas.y);
		}
		
		
		protected function onCopyClicked(from:Button) : void{
			var i:int;
			var stat:StatisticInfo;
			
			var outXML:String = "<debugFrameData><statistics>";
			var statCount:int = _statistics.length;
			for(i=0; i<statCount; i++){
				stat = _statistics[i];
				outXML += "<statistic id='"+stat.id+"' name='"+stat.name+"' colour='#"+stat.colour.toString(16)+"'/>";
			}
			
			outXML += "</statistics><frames>";
			var frameCount:int = _frames.length;
			for(i=0; i<frameCount; i++){
				var frameRecord:FrameRecord = _frames[i];
				outXML += "<frame time='"+frameRecord.time+"'>";
				for(var j:int=0; j<statCount; j++){
					stat = _statistics[j];
					var record:Number = frameRecord.statistics[stat];
					if(!isNaN(record))outXML += "<statRecord statId='"+stat.id+"' value='"+frameRecord.statistics[stat]+"'/>"
				}
				outXML += "</frame>"
			}
			outXML += "</frames></debugFrameData>";
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT,outXML);
		}
		protected function onEnterFrame():void{
			var record:FrameRecord = new FrameRecord(getTimer());
			var stats:Dictionary = new Dictionary();
			var doDraw:Boolean = (_frames.length==0 || _frames.length%_framesPerPixel==_framesPerPixel-1);
			
			var width:Number;
			var height:Number;
			if(doDraw){
				width = _bitmapData.width;
				height = _bitmapData.height;
				
				_bitmapData.scroll(-1,0);
				
				if(shouldDoGrid(_frames.length)){
					_bitmapData.fillRect(_fillRect,_gridColour);
				}else{
					_bitmapData.fillRect(_fillRect,_backgroundColour);
					_bitmapData.setPixel(width-1,height*_maxPadding,_gridColour);
				}
			}
			for each(var stat:StatisticInfo in _statistics){
				var value:Number = stat.statisticProvider.numericalValue;
				stats[stat] = value;
				if(doDraw){
					var max:Number = stat.maxProvider.value;
					_bitmapData.setPixel(width-1,calcPixel(height,value,max),stat.colour);
				}
			}
			record.statistics = stats;
			_frames.push(record);
		}
		public function setSize(width:int, height:int):void{
			if(!_bitmapData || _bitmapData.width!=width || _bitmapData.height!=height){
				_fillRect.y = 0;
				_fillRect.x = width-1;
				_fillRect.width = 1;
				_fillRect.height = height;
				
				_maxRect.width = width;
				_maxRect.height = 1;
				
				_bitmapData = new BitmapData(width,height,false,_backgroundColour);
				if(_bitmap)_bitmap.bitmapData = _bitmapData;
				
				if(_displayChanged)_displayChanged.perform(this);
				redrawAll(false);
				performMeasChanged();
			}
		}
		public function addStatistic(statisticProvider:INumberProvider, maxProvider:INumberProvider, colour:Number, name:String):void{
			maxProvider.numericalValueChanged.addHandler(onMaxChanged);
			_statistics.push(new StatisticInfo(_statId++, statisticProvider, maxProvider, colour, name));
		}
		protected function onMaxChanged(from:INumberProvider):void{
			redrawAll(true);
		}
		protected function redrawAll(refillBackground:Boolean):void{
			if(refillBackground){
				_bitmapData.fillRect(_bitmapData.rect,_backgroundColour);
			}
			var width:Number = _bitmapData.width;
			var height:Number = _bitmapData.height;
			var frameCount:Number = _frames.length;
			
			_maxRect.y = height*_maxPadding;
			_bitmapData.fillRect(_maxRect,_gridColour);
			for(var i:int=0; i<width; i++){
				var x:Number = width-1-i;
				var framesBack:int = i*_framesPerPixel;
				if(frameCount<=framesBack){
					break;
				}else{
					var frameIndex:int = frameCount-1-framesBack;
					var frameRecord:FrameRecord = _frames[frameIndex];
					
					if(shouldDoGrid(frameIndex)){
						_fillRect.x = x;
						_bitmapData.fillRect(_fillRect,_gridColour);
					}
					for(var j:* in frameRecord.statistics){
						var stat:StatisticInfo = (j as StatisticInfo);
						var max:Number = stat.maxProvider.value;
						var value:Number = frameRecord.statistics[j];
						_bitmapData.setPixel(x,calcPixel(height,value,max),stat.colour);
					}
				}
			}
			_fillRect.x = width-1;
		}
		protected function calcPixel(height:int, value:Number, max:Number):int{
			var invFraction:Number = 1-(value/max);
			var yPos:int = (_maxPadding*height)+(invFraction*(height-1)*(1-_maxPadding));
			if(yPos<0)yPos = 0;
			else if(yPos>height-1)yPos = height-1;
			return yPos;
		}
		protected function shouldDoGrid(frameIndex:int):Boolean{
			var gridPerPixel:Number = _framesPerGrid/_framesPerPixel;
			var gridRem:Number = (frameIndex%_framesPerGrid);
			if(gridRem>_framesPerGrid/2)gridRem = _framesPerGrid-gridRem;
			return (gridRem/gridPerPixel<=gridPerPixel%1);
		}
	}
}
import flash.utils.Dictionary;

import org.farmcode.data.dataTypes.INumberProvider;

class StatisticInfo{
	public var statisticProvider:INumberProvider;
	public var maxProvider:INumberProvider;
	public var colour:Number;
	public var id:int;
	public var name:String;
	
	public function StatisticInfo(id:int, statisticProvider:INumberProvider, maxProvider:INumberProvider, colour:Number, name:String){
		this.id = id;
		this.statisticProvider = statisticProvider;
		this.maxProvider = maxProvider;
		this.colour = colour;
		this.name = name;
	}
}
class FrameRecord{
	public var time:Number;
	// StatisticInfo > number
	public var statistics:Dictionary;
	
	public function FrameRecord(time:int){
		this.time = time;
	}
}