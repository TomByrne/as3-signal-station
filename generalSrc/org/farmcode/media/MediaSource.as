package org.farmcode.media
{
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.display.behaviour.ILayoutViewBehaviour;
	
	public class MediaSource implements IMediaSource
	{
		/**
		 * @inheritDoc
		 */
		public function get loadProgressChanged():IAct{
			if(!_loadProgressChanged)_loadProgressChanged = new Act();
			return _loadProgressChanged;
		}
		/**
		 * @inheritDoc
		 */
		public function get loadTotalChanged():IAct{
			if(!_loadTotalChanged)_loadTotalChanged = new Act();
			return _loadTotalChanged;
		}
		
		
		public function get loadUnits():String{
			return null;
		}
		public function get loadProgress():Number{
			return _loadProgress;
		}
		public function get loadTotal():Number{
			return _loadTotal;
		}
		
		public function get cacheMediaSources():int{
			return _cacheMediaDisplays;
		}
		public function set cacheMediaSources(value:int):void{
			if(_cacheMediaDisplays!=value){
				_cacheMediaDisplays = value;
				while(_cache.length>_cacheMediaDisplays){
					var display:ILayoutViewBehaviour = _cache.pop();
					delete _allMediaDisplays[display];
					destroyMediaDisplay(display);
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get loadCompleted():IAct{
			if(!_loadCompleted)_loadCompleted = new Act();
			return _loadCompleted;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get loadFailed():IAct{
			if(!_loadFailed)_loadFailed = new Act();
			return _loadFailed;
		}
		
		protected var _loadFailed:Act;
		protected var _loadCompleted:Act;
		protected var _loadProgressChanged:Act;
		protected var _loadTotalChanged:Act;
		
		protected var _loadProgress:Number;
		protected var _loadTotal:Number;
		protected var _isCompleted:Boolean;
		
		protected var _cacheMediaDisplays:int = 1;
		protected var _cache:Array = [];
		protected var _allMediaDisplays:Dictionary = new Dictionary(true);
		
		
		public function MediaSource(){
		}
		
		public function takeMediaDisplay():ILayoutViewBehaviour{
			if(_cache.length){
				return _cache.pop();
			}else{
				var ret:ILayoutViewBehaviour = createMediaDisplay();
				_allMediaDisplays[ret] = true;
				return ret;
			}
		}
		public function returnMediaDisplay(value:ILayoutViewBehaviour):void{
			if(_cache.length<_cacheMediaDisplays){
				_cache.push(value);
			}else{
				delete _allMediaDisplays[value];
				destroyMediaDisplay(value);
			}
		}
		
		protected function setLoadProps(progress:Number, total:Number):void{
			
			if(progress>total && total!=-1){
				throw new Error("Progress cannot be greater than total");
			}
			
			if(progress!=_loadProgress){
				_loadProgress = progress;
				if(_loadProgressChanged)_loadProgressChanged.perform(this);
			}
			if(total!=_loadTotal){
				_loadTotal = total;
				if(_loadTotalChanged)_loadTotalChanged.perform(this);
			}
			var isCompleted:Boolean = (progress>=total);
			if(_isCompleted != isCompleted){
				_isCompleted = isCompleted;
				if(isCompleted && _loadCompleted){
					_loadCompleted.perform(this);
				}
			}
		}
		
		protected function createMediaDisplay():ILayoutViewBehaviour{
			// override me
			return null;
		}
		protected function destroyMediaDisplay(value:ILayoutViewBehaviour):void{
			// override me
		}
	}
}