package lf.media.core.control.stream
{
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import lf.media.core.model.flv.HeadTag;
	

	public class FlvHeadTagC
	{
		public function FlvHeadTagC()
		{
		}
		
		public function init(sourceB:URLStream,buffer:ByteArray):void{
			this._buffer = buffer;
			this._sourceB = sourceB;
		}
		
		public function get  isFlvHead():Boolean{
			var str:String = "";
			if(_buffer.bytesAvailable<3){
				_sourceB.readBytes(_buffer,_buffer.bytesAvailable,3-_buffer.bytesAvailable);
			}
			
			str += _buffer[0].toString(16);
			str += _buffer[1].toString(16);
			str += _buffer[2].toString(16);
			return str == "464c56";
		}
		
		
		public function get tagData():HeadTag{
			var ht:HeadTag = new HeadTag();
			var b:ByteArray = new ByteArray();
			
			if(_buffer.bytesAvailable< ht.size){
				_sourceB.readBytes(_buffer,_buffer.bytesAvailable,ht.size-_buffer.bytesAvailable);
			}
			
			_buffer.position = 0;
			ht.pos = ht.size;
			_buffer.readBytes(b,0,ht.size);
			ht.data = b;
			_buffer.position = ht.size;
			return ht;
		}
		
		
		private var _sourceB:URLStream = null;
		private var _buffer:ByteArray = null;
		
		
	}
}