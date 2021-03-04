package com.reactnativealibc;

import com.alibaba.baichuan.trade.biz.AlibcConstants;
import com.alibaba.baichuan.trade.biz.AlibcTradeCallback;
import com.alibaba.baichuan.trade.biz.context.AlibcTradeResult;
import com.alibaba.baichuan.trade.biz.core.taoke.AlibcTaokeParams;
import com.alibaba.baichuan.trade.biz.login.AlibcLogin;
import com.alibaba.baichuan.trade.biz.login.AlibcLoginCallback;
import com.alibaba.baichuan.trade.common.utils.AlibcLogger;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.Arguments;

import android.app.Application;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.widget.Toast;

import androidx.annotation.Nullable;

import com.ali.auth.third.ui.context.CallbackContext;
import com.ali.auth.third.core.model.Session;
import com.alibaba.baichuan.android.trade.AlibcTradeSDK;
import com.alibaba.baichuan.android.trade.callback.AlibcTradeInitCallback;

import com.alibaba.baichuan.android.trade.AlibcTrade;
import com.alibaba.baichuan.android.trade.model.AlibcShowParams;
import com.alibaba.baichuan.android.trade.model.OpenType;
import com.alibaba.baichuan.android.trade.page.AlibcAddCartPage;
import com.alibaba.baichuan.android.trade.page.AlibcBasePage;
import com.alibaba.baichuan.android.trade.page.AlibcDetailPage;
import com.alibaba.baichuan.android.trade.page.AlibcMyCartsPage;
import com.alibaba.baichuan.android.trade.page.AlibcShopPage;
import com.alibaba.baichuan.android.trade.callback.AlibcTradeInitCallback;

import java.util.HashMap;
import java.util.Map;

import android.view.View;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.webkit.WebChromeClient;
import com.facebook.react.uimanager.events.RCTEventEmitter;

import java.util.List;
import android.util.Log;
import android.widget.Toast;

public class AlibcModule extends ReactContextBaseJavaModule {

  private static ReactContext sContext;
  private static final String TAG = "AlibcModule";

  private final static String NOT_LOGIN = "not login";
  private final static String INVALID_TRADE_RESULT = "invalid trade result";
  private final static String INVALID_PARAM = "invalid";

  private Map<String, String> exParams;// yhhpass参数
  private AlibcShowParams alibcShowParams;// 页面打开方式，默认，H5，Native
  private AlibcTaokeParams alibcTaokeParams = null;// 淘客参数，包括pid，unionid，subPid
  private static Activity mActivity;
  private final ActivityEventListener mActivityEventListener = new BaseActivityEventListener() {
    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent intent) {
      CallbackContext.onActivityResult(requestCode, resultCode, intent);
    }
  };

  static private AlibcModule mAlibcModule = null;

  static public AlibcModule sharedInstance(ReactApplicationContext context) {
    if (mAlibcModule == null)
      return new AlibcModule(context);
    else
      return mAlibcModule;
  }

  public static void init(Activity activity) {
    if (activity == null)
      return;
    mActivity = activity;
  }

  @ReactMethod
  public void multiply(int a, int b, Promise promise) {
    promise.resolve(a * b);
  }

  public AlibcModule(ReactApplicationContext reactApplicationContext) {
    super(reactApplicationContext);
    sContext = reactApplicationContext;
    sContext.addActivityEventListener(mActivityEventListener);

    alibcShowParams = new AlibcShowParams();// OpenType.Auto, false
    alibcShowParams.setOpenType(OpenType.Auto);
    alibcShowParams.setClientType("taobao");
    alibcShowParams.setBackUrl("alisdk://");
    exParams = new HashMap<>();
    exParams.put(AlibcConstants.ISV_CODE, "rnappisvcode");
  }

  @Override
  public String getName() {
    return "Alibc";
  }

  /**
   * 初始化
   */
  @ReactMethod
  public void init(final String appkey, final String pid, final Promise promise) {
    alibcTaokeParams = new AlibcTaokeParams("", "", "");
    alibcTaokeParams.extraParams = new HashMap<>();
    alibcTaokeParams.extraParams.put("taokeAppkey", appkey);
    alibcTaokeParams.setPid(pid);// pid
    AlibcTradeSDK.asyncInit(getCurrentActivity().getApplication(), new AlibcTradeInitCallback() {
      @Override
      public void onSuccess() {
        Toast.makeText(sContext, "初始化成功", Toast.LENGTH_SHORT).show();
        promise.resolve(true);
      }

      @Override
      public void onFailure(int code, String msg) {
        Toast.makeText(sContext, "初始化失败:" + msg, Toast.LENGTH_SHORT).show();
        WritableMap map = Arguments.createMap();
        map.putInt("code", code);
        map.putString("msg", msg);
        promise.resolve(map);
      }
    });
    Toast.makeText(sContext, "初始化中", Toast.LENGTH_SHORT).show();
  }

  /**
   * 登录
   */
  @ReactMethod
  public void login(final Promise promise) {
    AlibcLogin alibcLogin = AlibcLogin.getInstance();
    alibcLogin.showLogin(new AlibcLoginCallback() {
      @Override
      public void onSuccess(int loginResult, String openId, String userNick) {
        // 参数说明：
        // loginResult(0--登录初始化成功；1--登录初始化完成；2--登录成功)
        // openId：用户id
        // userNick: 用户昵称
        Session session = AlibcLogin.getInstance().getSession();
        WritableMap map = Arguments.createMap();
        map.putString("nick", session.nick);
        map.putString("avatarUrl", session.avatarUrl);
        map.putString("openId", session.openId);
        map.putString("openSid", session.openSid);
        map.putString("err", "1");
        promise.resolve(map);
      }

      @Override
      public void onFailure(int code, String msg) {
        WritableMap map = Arguments.createMap();
        map.putInt("code", code);
        map.putString("msg", msg);
        map.putString("err", "0");
        promise.resolve(map);
      }
    });
  }

  /**
   * 是否登录
   */
  @ReactMethod
  public void isLogin(final Promise promise) {
    promise.resolve(AlibcLogin.getInstance().isLogin());
  }

  /**
   * 登录用户信息
   */
  @ReactMethod
  public void getUser(final Promise promise) {
    if (AlibcLogin.getInstance().isLogin()) {
      Session session = AlibcLogin.getInstance().getSession();
      WritableMap map = Arguments.createMap();
      map.putString("nick", session.nick);
      map.putString("avatarUrl", session.avatarUrl);
      map.putString("openId", session.openId);
      map.putString("openSid", session.openSid);
      map.putString("err", "1");
      promise.resolve(map);
    } else {
      promise.resolve(false);
    }

  }

  /**
   * 退出登录
   */
  @ReactMethod
  public void logout(final Promise promise) {
    AlibcLogin alibcLogin = AlibcLogin.getInstance();

    alibcLogin.logout(new AlibcLoginCallback() {
      @Override
      public void onSuccess(int loginResult, String openId, String userNick) {
        // 参数说明：
        // loginResult(3--登出成功)
        // openId：用户id
        // userNick: 用户昵称
        if (loginResult == 3) {
          promise.resolve(true);
        } else {
          promise.resolve(false);
        }
      }

      @Override
      public void onFailure(int code, String msg) {
        WritableMap map = Arguments.createMap();
        map.putInt("code", code);
        map.putString("msg", msg);
        promise.resolve(msg);
      }
    });
  }

  @ReactMethod
  public void open(final ReadableMap param, final String openType, final String clientType, final Promise promise) {
    alibcShowParams = new AlibcShowParams();// OpenType.Auto, false
    alibcShowParams.setClientType(clientType);
    alibcShowParams.setBackUrl("alisdk://");

    System.out.println("Alibc show clientType:" + clientType + "  openType:" + openType);
    switch (openType) {
      case "Auto":
        alibcShowParams.setOpenType(OpenType.Auto);
        break;
      case "H5":
        alibcShowParams.setOpenType(OpenType.Auto);
        break;
      case "Native":
        alibcShowParams.setOpenType(OpenType.Native);
        break;
      default:
        alibcShowParams.setOpenType(OpenType.Auto);
        break;
    }

    AlibcTaokeParams taokeParams = this.alibcTaokeParams;
    // taokeParams.setPid("mm_112883640_11584347_72287650277");

    Map<String, String> trackParams = new HashMap<>();

    // 调用类型
    String type = param.getString("type");
    if (type.equals("url")) {
      // 通过百川内部的webview打开页面
      String url = param.getString("url");
      AlibcTrade.openByUrl(getCurrentActivity(), "", url, null, new WebViewClient(), new WebChromeClient(), alibcShowParams,
          taokeParams, trackParams, new AlibcTradeCallback() {
            @Override
            public void onTradeSuccess(AlibcTradeResult tradeResult) {
              AlibcLogger.i("MainActivity", "request success");
              promise.resolve(true);
            }

            @Override
            public void onFailure(int code, String msg) {
              AlibcLogger.e("MainActivity", "code=" + code + ", msg=" + msg);
              if (code == -1) {
                Toast.makeText(sContext, msg, Toast.LENGTH_SHORT).show();
              }
              WritableMap map = Arguments.createMap();
              map.putInt("code", code);
              map.putString("msg", msg);
              promise.resolve(map);
            }
          });

    } else {
      AlibcBasePage mPage = new AlibcBasePage();
      switch (type) {
        case "detail":
          mPage = new AlibcDetailPage(param.getString("payload"));
          break;
        case "shop":
          mPage = new AlibcShopPage(param.getString("payload"));
          break;
        case "addCard":
          mPage = new AlibcAddCartPage(param.getString("payload"));
          break;
        case "mycard":
          mPage = new AlibcMyCartsPage();
          break;
        default:
          promise.resolve(false);
          break;
      }

      AlibcTrade.openByBizCode(getCurrentActivity(), mPage, null, new WebViewClient(), new WebChromeClient(), type,
          alibcShowParams, taokeParams, trackParams, new AlibcTradeCallback() {
            @Override
            public void onTradeSuccess(AlibcTradeResult tradeResult) {
              // 交易成功回调（其他情形不回调）
              AlibcLogger.i("MainActivity", "open detail page success");
              promise.resolve(true);
            }

            @Override
            public void onFailure(int code, String msg) {
              AlibcLogger.e("MainActivity", "code=" + code + ", msg=" + msg);
              if (code == -1) {
                Toast.makeText(sContext, "唤端失败，失败模式为none", Toast.LENGTH_SHORT).show();
              }
              WritableMap map = Arguments.createMap();
              map.putInt("code", code);
              map.putString("msg", msg);
              promise.resolve(map);
            }
          });
    }
  }
}
