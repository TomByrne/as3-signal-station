package org.farmcode.sodalityLibrary.control.modifiers
{
	import org.farmcode.sodalityLibrary.control.members.ISourceMember;
	
	import flash.events.Event;
	
	public class AddMemberModifier extends AbstractNumberModifier
	{
		private var member: ISourceMember;
		private var _monitorMember: Boolean;
		
		public function AddMemberModifier(member:ISourceMember, monitorMember: Boolean = false){
			super();
			this.member = member;
			this.monitorMember = monitorMember;
		}
		
		public function set monitorMember(value: Boolean): void
		{
			if (value != this.monitorMember)
			{
				this._monitorMember = value;
				if (this.monitorMember)
				{
					this.member.addEventListener(Event.CHANGE, this.handleMemberChange);
				}
				else
				{
					this.member.removeEventListener(Event.CHANGE, this.handleMemberChange);
				}
			}
		}
		public function get monitorMember(): Boolean
		{
			return this._monitorMember;
		}
		
		private function handleMemberChange(event: Event): void
		{
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		
		override public function inputNumber(value:Number, oldValue:Number):Number
		{
			var offset:Number = (member.value as Number);
			if(isNaN(offset))throw new Error("AddMemberModifier must point to a numerical member");
			return value + offset;
		}	
	}
}