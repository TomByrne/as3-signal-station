package org.tbyrne.display.controls.toolTip
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.display.core.ILayoutView;

	public class ToolTipTrigger extends AbstractToolTipTrigger
	{
		override public function get data():*{
			return _data?_data:(_dataField?_anchorView[_dataField]:null);
		}
		public function set data(value:*):void{
			if(_data != value){
				_data = value;
				if(_dataAnchorChanged)_dataAnchorChanged.perform(this);
			}
		}
		
		public function set anchorView(value:ILayoutView):void{
			setAnchorView(value);
		}
		
		public function get dataField():String{
			return _dataField;
		}
		public function set dataField(value:String):void{
			if(_dataField!=value){
				_dataField = value;
				if(_dataAnchorChanged && !_data)_dataAnchorChanged.perform(this);
			}
		}
		
		override public function get tipType():String{
			return _tipType;
		}
		public function set tipType(value:String):void{
			_tipType = value;
		}
		
		public function get activateActName():String{
			return _activateActName;
		}
		public function set activateActName(value:String):void{
			if(_activateActName!=value){
				if(_actTarget && _activateActName){
					removeHandler(_activateActName, onActivate);
				}
				_activateActName = value;
				if(_actTarget && _activateActName){
					addHandler(_activateActName, onActivate);
				}
			}
		}
		
		public function get deactivateActName():String{
			return _deactivateActName;
		}
		public function set deactivateActName(value:String):void{
			if(_deactivateActName!=value){
				if(_actTarget && _deactivateActName){
					removeHandler(_deactivateActName, onDeactivate);
				}
				_deactivateActName = value;
				if(_actTarget && _deactivateActName){
					addHandler(_deactivateActName, onDeactivate);
				}
			}
		}
		
		public function get activeProperty():String{
			return _activeProperty;
		}
		public function set activeProperty(value:String):void{
			if(_activeProperty!=value){
				_activeProperty = value;
				if(_activeProperty && _actTarget){
					checkValue();
				}
			}
		}
		
		public function set changeActName(value:String):void{
			activateActName = value;
			deactivateActName = value;
		}
		public function get actTarget():Object{
			return _actTarget;
		}
		public function set actTarget(value:Object):void{
			if(_actTarget!=value){
				if(_actTarget){
					if(_activateActName)removeHandler(_activateActName, onActivate);
					if(_deactivateActName)removeHandler(_deactivateActName, onDeactivate);
				}
				_actTarget = value;
				if(_actTarget){
					if(_activeProperty)checkValue();
					if(_activateActName)addHandler(_activateActName, onActivate);
					if(_deactivateActName)addHandler(_deactivateActName, onDeactivate);
				}
			}
		}
		
		private var _actTarget:Object;
		private var _tipType:String = ToolTipTypes.CONTEXTUAL_TIP;
		private var _dataField:String;
		private var _activeProperty:String;
		private var _deactivateActName:String;
		private var _activateActName:String;
		
		public function ToolTipTrigger(tipType:String=null){
			super();
			this.tipType = tipType;
		}
		protected function addHandler(actName:String, handler:Function):void{
			var act:IAct = _actTarget[actName];
			act.addHandler(handler);
		}
		protected function removeHandler(actName:String, handler:Function):void{
			var act:IAct = _actTarget[actName];
			act.removeHandler(handler);
		}
		protected function onActivate(... params):void{
			if(_deactivateActName==_activateActName || _activeProperty){
				checkValue();
			}else if(_data){
				setActive(true);
			}
		}
		protected function onDeactivate(... params):void{
			if(_deactivateActName==_activateActName){
				// ignore (onActivate will catch it)
			}else if(_activeProperty){
				checkValue();
			}else{
				setActive(false);
			}
		}
		protected function checkValue():void{
			if(_data){
				if(!_activeProperty)Log.error( "ToolTipTrigger.checkValue: activeProperty must be set if deactivateActName and activateActName are the same");
				var value:Boolean = _actTarget[_activeProperty];
				setActive(value);
			}else{
				setActive(false);
			}
		}
	}
}