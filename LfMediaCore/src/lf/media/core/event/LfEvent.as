package lf.media.core.event
{
	import flash.events.Event;
	
	public class LfEvent extends Event
	{
		
		public function LfEvent(type:String, data:Object,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this._data = data;
			super(type, bubbles, cancelable);
		}
		
		
		public function get data():Object{
			return _data;
		}
		
		
		private var _data:Object;
		
		
	}
}