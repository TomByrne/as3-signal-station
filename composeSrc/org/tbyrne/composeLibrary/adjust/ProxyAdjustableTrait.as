package org.tbyrne.composeLibrary.adjust
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.composeLibrary.types.adjust.IAdjustableTrait;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	
	public class ProxyAdjustableTrait extends AbstractTrait implements IAdjustableTrait
	{
		/**
		 * @inheritDoc
		 */
		public function get adjustNamesChanged():IAct{
			return (_adjustNamesChanged || (_adjustNamesChanged = new Act()));
		}
		
		protected var _adjustNamesChanged:Act;
		
		
		public function get adjustNames():Vector.<String>{
			return _adjustNames;
		}
		public function set adjustNames(value:Vector.<String>):void{
			if(_adjustNames!=value){
				_adjustNames = value;
				if(_adjustNamesChanged)_adjustNamesChanged.perform(this);
			}
		}
		public function get adjustDest():*{
			return _destination;
		}
		public function set destination(value:*):void{
			_destination = value;
		}
		
		private var _destination:*;
		private var _adjustNames:Vector.<String>;
		private var _defaults:Dictionary;
		
		public function ProxyAdjustableTrait(adjustNames:Array=null, destination:*=null){
			super();
			_adjustNames = Vector.<String>(adjustNames);
			this.destination = destination;
			_defaults = new Dictionary();
		}
		
		public function applyAdjustment(property:String, value:*):void{
			_defaults[property] = adjustDest[property];
			adjustDest[property] = value;
		}
		
		public function clearAdjustment(property:String):void{
			adjustDest[property] = _defaults[property];
			delete _defaults[property];
		}
	}
}