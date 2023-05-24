use anyhow::Result;
use opencv::core::*;
use opencv::*;
use tch::*;

fn main() -> Result<()> {
    let cwd_img = std::env::current_dir().unwrap();
    let mut img_path = cwd_img.into_os_string().into_string().unwrap();
    let img_file = "/0AJ9@32@143297.jpg".to_string();
    img_path.push_str(&img_file);
    let mat: Mat = opencv::imgcodecs::imread(&img_path, opencv::imgcodecs::IMREAD_GRAYSCALE)?;

    let cwd = std::env::current_dir().unwrap();
    let mut path_model = cwd.into_os_string().into_string().unwrap();
    let model_file = "/976_trace_OCR_0.9330357142857143_val_f32.pt".to_string();
    path_model.push_str(&model_file);
    let mut model_ocr = tch::CModule::load(path_model)?;
    model_ocr.set_eval();
    model_ocr.to(tch::Device::Cuda(0), tch::Kind::Float, false);

    let resize_to = (32, 128);
    let output_transform = transform_img_mat_mat(mat, resize_to);
    let mut output = match output_transform {
        Ok(mat) => mat,
        Err(err) => panic!("Problem opening the file: {:?}", err),
    };
    let normalized_tensor_transform = transform_img_mat_tensor(&mut output, resize_to);
    let normalized_tensor = match normalized_tensor_transform {
        Ok(tensor) => tensor,
        Err(err) => panic!("Problem opening the file: {:?}", err),
    };

    let probabilites = model_ocr
        .forward_ts(&[normalized_tensor])?
        .softmax(-1, tch::Kind::Float);
    let mut decoded = String::new();
    let vocab = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-.# ~";
    let mut char_list: std::collections::HashMap<usize, char> =
        (1..=vocab.len()).zip(vocab.chars()).collect();
    char_list.insert(0, '`');

    let mut position = vec![];
    let shape_of_time_step = probabilites.size()[0];
    let predicted_class = tch::Tensor::squeeze(&probabilites.argmax(2, true));
    for j in 0..shape_of_time_step {
        let k =
            tch::Tensor::int64_value(&tch::Tensor::squeeze(&predicted_class.i(j)), &[]) as usize;
        if position.is_empty() {
            if k != 0 {
                position.push(k);
                decoded.push(char_list[&k]);
            }
        } else if position[position.len() - 1] != k && k != 0 {
            position.push(k);
            decoded.push(char_list[&k]);
        }
    }
    print!("{:?}\r\n", decoded);
    print!("{:?}\r\n", position);
    print!("{:?}\r\n", shape_of_time_step);
    highgui::named_window("hello opencv!", 0)?;
    highgui::imshow("hello opencv!", &output)?;
    highgui::wait_key(10000)?;
    Ok(())
}

fn transform_img_mat_mat(mat: Mat, resize_to: (i32, i32)) -> Result<Mat, opencv::Error> {
    let shape = mat.size()?;
    let h = shape.height as usize;
    let w = shape.width as usize;
    //let data = mat.data_typed::<u8>()?;
    let fx = resize_to.1 as f64 / w as f64;
    let fy = resize_to.0 as f64 / h as f64;
    let f = f64::min(fx, fy);
    let _h = h as f64 * f;
    let _w = w as f64 * f;
    let target_size = Size::new(_w as i32, _h as i32);
    let mut img_resize = Mat::default();
    opencv::imgproc::resize(
        &mat,
        &mut img_resize,
        target_size,
        0.0,
        0.0,
        opencv::imgproc::INTER_LINEAR,
    )?;
    let h_img_resize = img_resize.size()?.height;
    let w_img_resize = img_resize.size()?.width;
    let mut output = Mat::default();
    let top = 0; // Number of pixels for the top border
    let bottom = resize_to.0 - h_img_resize; // Number of pixels for the bottom border
    let left = 0; // Number of pixels for the left border
    let right = resize_to.1 - w_img_resize; // Number of pixels for the right border
    let border_type = opencv::core::BORDER_CONSTANT; // Border type
    let border_value = opencv::core::Scalar::default(); // Border value (defaults to black)
    opencv::core::copy_make_border(
        &img_resize,
        &mut output,
        top,
        bottom,
        left,
        right,
        border_type,
        border_value,
    )?;
    return Ok(output);
}

fn transform_img_mat_tensor(
    output: &mut Mat,
    resize_to: (i32, i32),
) -> Result<tch::Tensor, opencv::Error> {
    let resized_data = output.data_bytes_mut()?;
    let tensor = tch::Tensor::from_data_size(
        resized_data,
        &[resize_to.0 as i64, resize_to.1 as i64, 1_i64],
        tch::Kind::Uint8,
    );
    let tensor = tensor.to_kind(tch::Kind::Float) / 255;
    let tensor = tensor.to_device(tch::Device::Cuda(0));
    let tensor = tensor.permute([2, 0, 1]);
    let normalized_tensor = tensor.unsqueeze(0);
    return Ok(normalized_tensor);
}
