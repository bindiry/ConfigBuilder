package 
{
	import flash.data.EncryptedLocalStore;
	import flash.utils.ByteArray;

	public class Common
	{
		/** 相对路径的COOKIE前缀 */
		public static const COOKIE_NAME_RPATH:String = "CONFIG_BUILDER_RPATH";
		/** 导出路径的COOKIE前缀 */
		public static const COOKIE_NAME_EXPORT:String = "CONFIG_BUILDER_EXPORT";
		/** 允许压缩的文件列表 */
		public static const ALLOW_COMPRESS_FILE_TYPE:Array = ["xml", "json", "txt"];
		/** 文件类型xml */
		public static const TYPE_XML:String = "xml";
		/** 文件类型json */
		public static const TYPE_JSON:String = "json";
		/** 文件类型txt */
		public static const TYPE_TXT:String = "txt";
		
		public static var exportPathLabelText:String = "导出路径：";
		
		
		/**
		 * 检查扩展名是否在允许列表中 
		 * @param pFileExtName 扩展名
		 */
		public static function fileIsAllow(pFileName:String):Boolean
		{
			return (ALLOW_COMPRESS_FILE_TYPE.indexOf(pFileName) > -1) ? true : false;
		}
		
		/**
		 * 获取URL中的文件扩展名 
		 * @param pUrl 以文件名结束的URL
		 */
		public static function getExtensionName(pUrl:String):String
		{
			return pUrl.substring(pUrl.lastIndexOf(".") + 1);
		}
		
		/** 保存数据到本地 */
		public static function saveCookie(pKey:String, pValue:String):void
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(pValue);
			EncryptedLocalStore.setItem(pKey, bytes);
		}
		
		/** 从本地读取数据 */
		public static function getCookie(pKey:String):String
		{
			var result:String;
			var bytes:ByteArray = EncryptedLocalStore.getItem(pKey);
			if (bytes)
			{
				result = bytes.readUTFBytes(bytes.length);
			}
			return result;
		}
	}
}