package org.farmcode.sodalityPlatformEngine.control.focusController
{
	import org.farmcode.sodalityLibrary.control.members.EventMember;
	import org.farmcode.sodalityLibrary.control.members.ProxyPropertyMember;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class FocusController
	{
		// Controls
		public function get focusXControl():ProxyPropertyMember{
			return _focusXControl;
		}
		public function get focusYControl():ProxyPropertyMember{
			return _focusYControl;
		}
		public function get focusOffsetXControl():ProxyPropertyMember{
			return _focusOffsetXControl;
		}
		public function get focusOffsetYControl():ProxyPropertyMember{
			return _focusOffsetYControl;
		}
		public function get snapFocusControl():EventMember{
			return _snapFocusControl;
		}
		
		// public
		public function set focusBounds(value:Rectangle):void{
			_focusBounds = value;
			_boundsInvalid = true;
			if(!lazyFocusAssessment)assessFocus();
		}
		public function get focusBounds():Rectangle{
			return _focusBounds;
		}
		public function set focusRange(value:Rectangle):void{
			_focusRange = value;
			_boundsInvalid = true;
			if(!lazyFocusAssessment)assessFocus();
		}
		public function get focusRange():Rectangle{
			return _focusRange;
		}
		
		public var lazyFocusAssessment:Boolean = false;
		
		private var _focusXControl:ProxyPropertyMember;
		private var _focusYControl:ProxyPropertyMember;
		private var _focusOffsetXControl:ProxyPropertyMember;
		private var _focusOffsetYControl:ProxyPropertyMember;
		private var _snapFocusControl:EventMember;
		
		private var _focus:Point = new Point();
		private var _focusOffset:Point = new Point();
		private var focusBundles:Array = [];
		
		private var _focusBounds:Rectangle;
		private var _focusRange:Rectangle;
		private var _boundsInvalid:Boolean;
		private var _limitedBounds:Rectangle;
				
		public function FocusController(){
			_focusXControl = new ProxyPropertyMember(_focus, "x", true);
			_focusYControl = new ProxyPropertyMember(_focus, "y", true);
			_focusOffsetXControl = new ProxyPropertyMember(_focusOffset,"x", true);
			_focusOffsetYControl = new ProxyPropertyMember(_focusOffset,"y", true);
			_snapFocusControl = new EventMember();
		}
		public function snapFocus(): void{
			_snapFocusControl.dispatchChange();
		}
		public function addFocusItem(item:IFocusItem): void{
			var index:int = getIndexByFocusItem(item);
			var bundle:FocusItemBundle;
			if(index!=-1){
				bundle = focusBundles.splice(index,1)[0];
			}else{
				bundle = new FocusItemBundle(item);
			}
			focusBundles.push(bundle);
			if(!lazyFocusAssessment)assessFocus();
		}
		public function removeFocusItem(item:IFocusItem): void{
			var index:int = getIndexByFocusItem(item);
			if(index!=-1){
				focusBundles.splice(index,1);
			}
			if(!lazyFocusAssessment)assessFocus();
		}
		public function getIndexByFocusItem(item:IFocusItem): int{
			for(var i:int=0; i< focusBundles.length; ++i){
				var bundle:FocusItemBundle = focusBundles[i];
				if(bundle.focusItem==item){
					return i;
				}
			}
			return -1;
		}
		public function addFocusOffsetItem(item:IFocusItem, offsetItem:IFocusOffsetItem): void{
			var bundle:FocusItemBundle = getBundleFor(item);
			if(!bundle){
				addFocusItem(item);
				bundle = getBundleFor(item);
			}
			var index:int = bundle.focusOffsets.indexOf(offsetItem);
			if(index!=-1){
				bundle.focusOffsets.splice(index,1);
			}
			bundle.focusOffsets.unshift(offsetItem);
			if(!lazyFocusAssessment)assessFocus();
		}
		public function removeFocusOffsetItem(item:IFocusItem, offsetItem:IFocusOffsetItem): void{
			var bundle:FocusItemBundle = item?getBundleFor(item):getCurrentBundle();
			var index:int = bundle.focusOffsets.indexOf(offsetItem);
			if(index!=-1){
				bundle.focusOffsets.splice(index,1);
			}
			if(!lazyFocusAssessment)assessFocus();
		}
		public function getCurrentBundle(): FocusItemBundle{
			return focusBundles[focusBundles.length-1];
		}
		public function getBundleFor(item:IFocusItem): FocusItemBundle{
			for each(var bundle:FocusItemBundle in focusBundles){
				if(bundle.focusItem==item){
					return bundle;
				}
			}
			return null;
		}
		public function assessFocus(): void{
			validateBounds();
			
			var newFocusX: Number = 0;
			var newFocusY: Number = 0;
			var newFocusOffsetX: Number = 0;
			var newFocusOffsetY: Number = 0;
			
			if(focusBundles.length){
				var bundle:FocusItemBundle = getCurrentBundle();
				var focX:Number = bundle.focusItem.focusX;
				var focY:Number = bundle.focusItem.focusY;
				
				if(!isNaN(focX))newFocusX += focX;
				if(!isNaN(focY))newFocusY += focY;
			
				var totalRatio:Number = 0;
				var closeOffsets:Array = [];
				for each(var offsetItem:IFocusOffsetItem in bundle.focusOffsets){
					if(offsetItem.focusRatio>0){
						focX = offsetItem.focusX;
						focY = offsetItem.focusY;
						if(!offsetItem.relative){
							focX -= newFocusX;
							focY -= newFocusY;
						}
						if(!isNaN(focX) && !isNaN(focY) && Math.abs(newFocusOffsetX-focX)<focusRange.width/2 && Math.abs(newFocusOffsetY-focY)<focusRange.height/2){
							closeOffsets.push(offsetItem);
							totalRatio += offsetItem.focusRatio;
							newFocusOffsetX += focX;
							newFocusOffsetY += focY;
						}
					}
				}
				newFocusOffsetX = newFocusOffsetY = 0;
				for each(offsetItem in bundle.focusOffsets){
					if(offsetItem.focusRatio>0){
						focX = offsetItem.focusX;
						focY = offsetItem.focusY;
						if(!offsetItem.relative){
							focX -= newFocusX;
							focY -= newFocusY;
						}
						newFocusOffsetX += focX*(offsetItem.focusRatio/totalRatio);
						newFocusOffsetY += focY*(offsetItem.focusRatio/totalRatio);
					}
				}
				if(_limitedBounds)
				{
					if (newFocusX < _limitedBounds.left){
						newFocusX = _limitedBounds.left;
					}else if (newFocusX>_limitedBounds.right){
						newFocusX = _limitedBounds.right;
					}
					
					if(newFocusY<_limitedBounds.top){
						newFocusY = _limitedBounds.top;
					}else if(newFocusY>_limitedBounds.bottom){
						newFocusY = _limitedBounds.bottom;
					}
					
					if (newFocusOffsetX + newFocusX < _limitedBounds.left){
						newFocusOffsetX = _limitedBounds.left - newFocusX;
					}else if (newFocusOffsetX+newFocusX>_limitedBounds.right){
						newFocusOffsetX = _limitedBounds.right-newFocusX;
					}
					
					if (newFocusOffsetY + newFocusY < _limitedBounds.top){
						newFocusOffsetY = _limitedBounds.top - newFocusY;
					}else if (newFocusOffsetY + newFocusY > _limitedBounds.bottom){
						newFocusOffsetY = _limitedBounds.bottom - newFocusY;
					}
				}
			}
				
			if(_focus.x != newFocusX){
				_focus.x = newFocusX;
				_focusXControl.dispatchChange();
			}
			if(_focus.y != newFocusY){
				_focus.y = newFocusY;
				_focusYControl.dispatchChange();
			}
			if(_focusOffset.x != newFocusOffsetX){
				_focusOffset.x = newFocusOffsetX;
				_focusOffsetXControl.dispatchChange();
			}
			if(_focusOffset.y != newFocusOffsetY){
				_focusOffset.y = newFocusOffsetY;
				_focusOffsetYControl.dispatchChange();
			}
		}
		private function validateBounds():void{
			if(_boundsInvalid){
				if(_focusRange && _focusBounds){
					_boundsInvalid = false;
					_limitedBounds = new Rectangle();
					
					if(_focusBounds.width>_focusRange.width){
						_limitedBounds.x = _focusBounds.x+_focusRange.width/2;
						_limitedBounds.width = _focusBounds.width-_focusRange.width;
					}else{
						_limitedBounds.x = _focusBounds.x+_focusBounds.width/2;
						_limitedBounds.width = 0;
					}
					if(_focusBounds.height>_focusRange.height){
						_limitedBounds.y = _focusBounds.y+_focusRange.height/2;
						_limitedBounds.height = _focusBounds.height-_focusRange.height;
					}else{
						_limitedBounds.y = _focusBounds.y+_focusBounds.height/2;
						_limitedBounds.height = 0;
					}
				}else{
					_limitedBounds = null;
				}
			}
		}
	}
}
import org.farmcode.sodalityPlatformEngine.control.focusController.IFocusItem;
import flash.utils.Dictionary;
	
class FocusItemBundle{
	public var focusItem:IFocusItem;
	public var focusOffsets:Array = [];
	
	public function FocusItemBundle(focusItem:IFocusItem){
		this.focusItem = focusItem;
	}
}