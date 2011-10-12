package org.tbyrne.display.containers.accordion
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.data.controls.IControlData;
	import org.tbyrne.display.core.ILayoutView;
	import org.tbyrne.display.layout.IMinimisableLayoutSubject;
	
	public interface IAccordionRenderer extends ILayoutView, IMinimisableLayoutSubject{
		
		/**
		 * handler(from:IAccordionRenderer)
		 */
		function get userChangedOpen():IAct;
		function set data(value:IControlData):void;
		function setOpen(value:Boolean):void;
	}
}