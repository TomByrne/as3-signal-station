package org.farmcode.sodalityPlatformEngine.control
{
	import org.farmcode.sodalityLibrary.control.AbstractControlScheme;
	import org.farmcode.sodalityLibrary.control.ControlBinding;
	import org.farmcode.sodalityLibrary.control.members.PropertyMember;
	import org.farmcode.sodalityLibrary.control.modifiers.AddMemberModifier;
	import org.farmcode.sodalityLibrary.control.modifiers.SmoothModifier;
	import org.farmcode.sodalityPlatformEngine.control.focusController.FocusController;

	public class FocusControlScheme extends AbstractControlScheme
	{
		
		public function FocusControlScheme(){
			super();
		}
		
		override protected function addBindings():void{
			super.addBindings();
			
			var cast:PlatformControllable = (controllable as PlatformControllable);
			
			if(cast){
				// Camera position
				var focus:FocusController = cast.focusController;
				//focus.autoApplyCameraChange = false;
				focus.focusXControl.autoChangeDispatch = true;
				focus.focusYControl.autoChangeDispatch = true;
				
				
				// Camera updating
				var smoothFocusX:PropertyMember = new PropertyMember(0);
				var smoothFocusY:PropertyMember = new PropertyMember(0);
				addBinding(new ControlBinding(focus.focusOffsetXControl,smoothFocusX,[new SmoothModifier(5,0.25,20,0.01)]));
				addBinding(new ControlBinding(focus.focusOffsetYControl,smoothFocusY,[new SmoothModifier(5,0.25,20,0.01)]));
				addBinding(new ControlBinding(focus.focusXControl, cast.cameraXControl, [new SmoothModifier(0.25,1,10,0.01),new AddMemberModifier(smoothFocusX,true)],true));
				addBinding(new ControlBinding(focus.focusYControl, cast.cameraYControl, [new SmoothModifier(0.25,1,10,0.01),new AddMemberModifier(smoothFocusY,true)],true));
				
				// Manual Snapping
				addBinding(new ControlBinding(focus.snapFocusControl, cast.cameraXControl, [new AddMemberModifier(focus.focusOffsetXControl),new AddMemberModifier(focus.focusXControl)],false));
				addBinding(new ControlBinding(focus.snapFocusControl, cast.cameraYControl, [new AddMemberModifier(focus.focusOffsetYControl),new AddMemberModifier(focus.focusYControl)],false));
				
				/*focus.focusOffsetXControl.dispatchChange();
				focus.focusOffsetYControl.dispatchChange();
				focus.snapFocus();*/
			}
		}
	}
}