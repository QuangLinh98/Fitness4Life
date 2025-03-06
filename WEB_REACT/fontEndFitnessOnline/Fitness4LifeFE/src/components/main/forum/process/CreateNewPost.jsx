import React, { useContext, useEffect, useState } from "react";
import { Form, Input, Upload, Button, message, Select } from "antd";
import { UploadOutlined } from "@ant-design/icons";
import { useNavigate, useLocation } from "react-router-dom";
import { CreateQuestion } from "../../../../serviceToken/ForumService";
import { getDecodedToken, getTokenData } from "../../../../serviceToken/tokenUtils";

const { Option } = Select;

const categoryOptions = [
    { value: "FORUM_POLICY", label: "Forum Policies" },
    { value: "FORUM_RULES", label: "Forum Rules" },
    { value: "MALE_FITNESS_PROGRAM", label: "Male Fitness Program" },
    { value: "FEMALE_FITNESS_PROGRAM", label: "Female Fitness Program" },
    { value: "GENERAL_FITNESS_PROGRAM", label: "General Fitness Program" },
    { value: "FITNESS_QA", label: "Fitness Q&A" },
    { value: "POSTURE_CORRECTION", label: "Posture & Exercise Form Correction" },
    { value: "NUTRITION_EXPERIENCE", label: "Nutrition Experience" },
    { value: "SUPPLEMENT_REVIEW", label: "Supplement Reviews" },
    { value: "WEIGHT_LOSS_QA", label: "Weight Loss Q&A" },
    { value: "MUSCLE_GAIN_QA", label: "Muscle Gain Q&A" },
    { value: "TRANSFORMATION_JOURNAL", label: "Transformation Journal" },
    { value: "FITNESS_CHATS", label: "Fitness-Related Chats" },
    { value: "TRAINER_DISCUSSION", label: "Personal Trainer Discussions" },
    { value: "NATIONAL_GYM_CLUBS", label: "National Gym Clubs" },
    { value: "FIND_WORKOUT_BUDDY", label: "Find a Workout Buddy - Team Workout" },
    { value: "SUPPLEMENT_MARKET", label: "Supplement Marketplace" },
    { value: "EQUIPMENT_ACCESSORIES", label: "Workout Equipment & Accessories" },
    { value: "GYM_TRANSFER", label: "Gym Transfer & Ownership" },
    { value: "MMA_DISCUSSION", label: "Mixed Martial Arts (MMA) Discussion" },
    { value: "CROSSFIT_DISCUSSION", label: "CrossFit Discussion" },
    { value: "POWERLIFTING_DISCUSSION", label: "Powerlifting Discussion" },
];


const statusOptions = [
    { value: "PENDING", label: "Pending (Chờ xử lý)" },
    { value: "UNDER_REVIEW", label: "Under Review (Đang duyệt)" },
    { value: "APPROVED", label: "Approved (Đã duyệt)" },
];

const CreateNewPost = () => {
    const [form] = Form.useForm();
    const [loading, setLoading] = useState(false);
    const navigate = useNavigate();
    const location = useLocation();
    const tokenData = getTokenData();
    const decotoken = getDecodedToken();
    // console.log("decotoken: ", decotoken);//tokenData.access_token

    useEffect(() => {
        const queryParams = new URLSearchParams(location.search);
        const categoryLabel = queryParams.get("category");

        if (categoryLabel) {
            // Tìm `value` dựa trên `label`
            const categoryValue = categoryOptions.find(
                (option) => option.label === categoryLabel
            )?.value;

            if (categoryValue) {
                form.setFieldsValue({ category: [categoryValue] }); // Điền `value` vào form
            }
        }
    }, [location, form]);

    const initialValues = {
        authorId: decotoken?.id || "Không xác định",
        author: decotoken?.fullName || "Không xác định",
        status: "PENDING",
    };

    const handleSubmit = async (values) => {
        const { title, content, tag, category, imageQuestionUrl, authorId, author, status } = values;

        const formData = new FormData();
        formData.append("title", title);
        formData.append("content", content);
        formData.append("tag", tag);
        formData.append("rolePost", "PUBLICED");
        formData.append("status", status);
        formData.append("authorId", authorId);
        formData.append("author", author);

        if (category && category.length > 0) {
            category.forEach((cat) => formData.append("category", cat));
        }

        if (imageQuestionUrl && imageQuestionUrl.length > 0) {
            imageQuestionUrl.forEach((file) => {
                formData.append("imageQuestionUrl", file.originFileObj || file);
            });
        }

        try {
            setLoading(true);
            const response = await CreateQuestion(formData, tokenData.access_token);
            // console.log("response: ", response);
            if (response.status === 201) {
                message.success("Create a new post successfully!");
                navigate(`/forums/post-new`);
            } else {
                message.error(response.message || "Create a post failed!");
            }
        } catch (error) {
            message.error("An error occurred when creating a post!");
        } finally {
            setLoading(false);
        }
    };

    return (
        <section id="services">
            <div style={{ padding: "24px", maxWidth: "800px", margin: "0 auto" }}>
                <h1>Create a new post</h1>
                <Form
                    form={form}
                    layout="vertical"
                    onFinish={handleSubmit}
                    initialValues={initialValues}
                >
                    <Form.Item
                        label="Title"
                        name="title"
                        rules={[{ required: true, message: "Please enter title!" }]}
                    >
                        <Input placeholder="Enter post title" />
                    </Form.Item>

                    <Form.Item
                        label="Tag"
                        name="tag"
                        rules={[{ required: true, message: "Please enter tag!" }]}
                    >
                        <Input placeholder="Enter tag" />
                    </Form.Item>
                    <Form.Item
                        label="AuthorId"
                        name="authorId"
                        hidden
                    >
                        <Input disabled />
                    </Form.Item>
                    <Form.Item
                        label="Author"
                        name="author"
                        hidden
                    >
                        <Input disabled />
                    </Form.Item>
                    <Form.Item
                        label="Content"
                        name="content"
                        rules={[{ required: true, message: "Please enter content!" }]}
                    >
                        <Input.TextArea rows={4} placeholder="Enter post content" />
                    </Form.Item>

                    <Form.Item
                        label="Category"
                        name="category"
                        rules={[{ required: true, message: "Please enter category!" }]}
                    >
                        <Select
                            mode="multiple" // Cho phép chọn nhiều mục
                            placeholder="Enter category"
                            options={categoryOptions} // Danh sách các danh mục
                        />
                    </Form.Item>
                    <Form.Item
                        label="Status"
                        name="status"
                        rules={[{ required: true, message: "Please enter status!" }]}
                        hidden
                    >
                        <Select
                            placeholder="Select status"
                            options={statusOptions}
                        />
                    </Form.Item>

                    <Form.Item
                        label="Image"
                        name="imageQuestionUrl"
                        valuePropName="fileList"
                        getValueFromEvent={(e) => (Array.isArray(e) ? e : e?.fileList)}
                    >
                        <Upload
                            listType="picture"
                            beforeUpload={() => false}
                        >
                            <Button icon={<UploadOutlined />}>Upload image</Button>
                        </Upload>
                    </Form.Item>
                    <Form.Item>
                        <Button type="primary" htmlType="submit" loading={loading} block>
                            Create
                        </Button>
                    </Form.Item>
                </Form>
            </div>
        </section>
    );
};

export default CreateNewPost;
